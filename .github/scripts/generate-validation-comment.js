// Generates a FHIR validation results summary and writes it to markdown file for use in a comment.
// Environment variables:
//   - RESULTS_PATH       : path to the results.json file (optional, defaults to '.local/results/results.json')
//   - VALIDATION_OUTCOME : result of the validation job ('success' | 'failure' | 'cancelled'), optional
//   - RUN_URL            : URL to the workflow run, for linking to artifacts
//   - OUTPUT_PATH        : path for the generated comment body (optional, defaults to 'comment-body.md')
//   - GITHUB_SERVER_URL  : GitHub server URL (set automatically by Actions)
//   - GITHUB_REPOSITORY  : owner/repo (set automatically by Actions)
//   - GITHUB_SHA         : commit SHA (set automatically by Actions)
//   - GITHUB_WORKSPACE   : absolute path to the workspace root (set automatically by Actions)

const fs = require('node:fs');
const path = require('node:path');

const resultsPath = process.env.RESULTS_PATH ?? '.local/results/results.json';
const validationOutcome = process.env.VALIDATION_OUTCOME;
const runUrl = process.env.RUN_URL;
const outputPath = process.env.OUTPUT_PATH ?? 'comment-body.md';

const serverUrl = process.env.GITHUB_SERVER_URL;
const repository = process.env.GITHUB_REPOSITORY;
const sha = process.env.GITHUB_SHA;
const workspace = process.env.GITHUB_WORKSPACE;

function fileUrl(fullPath) {
  if (!serverUrl || !repository || !sha || !workspace) return fullPath;
  const relative = path.relative(workspace, fullPath);
  return `${serverUrl}/${repository}/blob/${sha}/${relative}`;
}

function fileDetails(operationOutcome) {
  const fullPath = operationOutcome.extension?.find(e =>
    e.url === 'http://hl7.org/fhir/StructureDefinition/operationoutcome-file'
  )?.valueString;
  if  (!fullPath) {
    return { filename: 'UNKNOWN', url: null}
  }
  const filename = path.basename(fullPath);
  const url = fileUrl(fullPath);

  return { filename, url }
}

const SEVERITY_ICON = { error: '❌', fatal: '❌', warning: '⚠️', information: 'ℹ️' };

let body;

if (!fs.existsSync(resultsPath)) {
  body = `## 🔬 FHIR Validation Results\n\n` +
         `❌ Validation did not produce a results file. ` +
         `Check the [workflow run](${runUrl}) for details.`;
} else {
  const raw = JSON.parse(fs.readFileSync(resultsPath, 'utf8'));

  // The output is either a single OperationOutcome or a Bundle of them
  const outcomes = raw.resourceType === 'Bundle'
    ? raw.entry.map(e => e.resource)
    : [raw];

  let errors = 0, warnings = 0, info = 0;

  // Group issues by file for a per-file breakdown
  const byFile = [];

  for (const oo of outcomes) {
    const {filename, url} = fileDetails(oo);

    const fileErrors = [], fileWarnings = [], fileInfo = [];

    for (const issue of (oo.issue ?? [])) {
      const sev = issue.severity;
      const icon = SEVERITY_ICON[sev] ?? 'ℹ️';
      const location = issue.expression?.[0] ?? '—';
      const message = issue.details?.text ?? issue.diagnostics ?? '—';
      const row = `| ${icon} \`${sev}\` | \`${location}\` | ${message} |`;

      if (sev === 'error' || sev === 'fatal') { errors++; fileErrors.push(row); }
      else if (sev === 'warning') { warnings++; fileWarnings.push(row); }
      else { info++; fileInfo.push(row); }
    }

    const allRows = [...fileErrors, ...fileWarnings, ...fileInfo];
    if (allRows.length > 0) {
      byFile.push({ filename, url, rows: allRows, hasErrors: fileErrors.length > 0 });
    }
  }

  const overall = errors > 0
    ? '❌ Validation failed'
    : warnings > 0
      ? '⚠️ Validation passed with warnings'
      : '✅ Validation passed';

  const summary = `**${errors}** error(s) · **${warnings}** warning(s) · **${info}** info`;

  let details = '';
  if (byFile.length > 0) {
    for (const { filename, url, rows, hasErrors } of byFile) {
      const open = hasErrors ? ' open' : '';
      const label = url ? `<a href="${url}"><code>${filename}</code></a>` : `<code>${filename}</code>`;
      details += `\n<details${open}>\n<summary>${label}</summary>\n\n`;
      details += `| Severity | Location | Message |\n|---|---|---|\n`;
      details += rows.join('\n');
      details += `\n\n</details>\n`;
    }
  } else {
    details = '\n_No issues found._\n';
  }

  body = `## 🔬 FHIR Validation Results\n\n` +
         `${overall} — ${summary}\n` +
         details +
         `\n> Full HTML report available in the [workflow run artifacts](${runUrl}).`;
}

const warning = validationOutcome === 'failure'
  ? `> [!WARNING]\n> The FHIR validator exited with errors. This should be reviewed before merging.\n\n`
  : '';

fs.writeFileSync(outputPath, `<!-- fhir-validation -->\n${warning}${body}`);
console.log(`Comment body written to ${outputPath}`);
