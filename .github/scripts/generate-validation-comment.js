// Generates a FHIR validation results summary and writes it to comment-body.md.
// Environment variables:
//   - RESULTS_PATH       : path to the results.json file (optional, defaults to '.local/results/results.json')
//   - VALIDATION_OUTCOME : result of the validation job ('success' | 'failure' | 'cancelled'), optional
//   - RUN_URL            : URL to the workflow run, for linking to artifacts
//   - OUTPUT_PATH        : path for the generated comment body (optional, defaults to 'comment-body.md')

const fs = require('fs');

const resultsPath = process.env.RESULTS_PATH ?? '.local/results/results.json';
const validationOutcome = process.env.VALIDATION_OUTCOME;
const runUrl = process.env.RUN_URL;
const OUTPUT_PATH = process.env.OUTPUT_PATH ?? 'comment-body.md'

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
  const rows = [];

  for (const oo of outcomes) {
    const file = oo.id
      ?? oo.extension?.find(e => e.url?.includes('source'))?.valueString
      ?? '—';

    for (const issue of (oo.issue ?? [])) {
      const sev = issue.severity;
      if (sev === 'error' || sev === 'fatal') errors++;
      else if (sev === 'warning') warnings++;
      else info++;

      const icon = (sev === 'error' || sev === 'fatal') ? '❌'
                 : sev === 'warning' ? '⚠️' : 'ℹ️';

      rows.push(`| ${icon} ${sev} | \`${file}\` | ${issue.details?.text ?? issue.diagnostics ?? ''} |`);
    }
  }

  const overall = errors > 0
    ? '❌ Validation failed'
    : warnings > 0
      ? '⚠️ Validation passed with warnings'
      : '✅ Validation passed';

  const summary = `**${errors}** error(s) · **${warnings}** warning(s) · **${info}** info`;

  const table = rows.length > 0
    ? `\n| Severity | File | Message |\n|---|---|---|\n${rows.join('\n')}`
    : '\n_No issues found._';

  body = `## 🔬 FHIR Validation Results\n\n` +
         `${overall} — ${summary}\n` +
         `${table}\n\n` +
         `> Full HTML report available in the [workflow run artifacts](${runUrl}).`;
}

const warning = validationOutcome === 'failure'
  ? `> [!WARNING]\n> The FHIR validator exited with errors. This check is non-blocking but should be reviewed before merging.\n\n`
  : '';

fs.writeFileSync(OUTPUT_PATH, `<!-- fhir-validation -->\n${warning}${body}`);
console.log('Comment body written to comment-body.md');
