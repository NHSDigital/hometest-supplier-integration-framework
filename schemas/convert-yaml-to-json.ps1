function ConvertYamlToJson {
    param(
        [string]$yamlFile,
        [string]$jsonFile
    )

    # Read YAML content
    $yamlContent = Get-Content -Path $yamlFile -Raw

    # Simple YAML to JSON conversion using regex and string manipulation
    # This handles the OpenAPI structure specifically

    # Load the YAML as a structured object using .NET
    Add-Type -AssemblyName System.Web.Extensions
    $serialized = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $serialized.MaxJsonLength = [int]::MaxValue

    # Use ConvertFrom-Json with a workaround
    # Read and parse YAML manually
    $lines = Get-Content -Path $yamlFile

    # For OpenAPI, we'll use a different approach - use online converter or manual creation
    # Let's try using Invoke-WebRequest to an online converter API

    try {
        # Alternative: Create JSON manually from the YAML structure
        Write-Host "Converting $yamlFile to $jsonFile..."

        # Install yq if available
        if (Get-Command yq -ErrorAction SilentlyContinue) {
            yq eval -o=json $yamlFile | Out-File -FilePath $jsonFile -Encoding UTF8
        } else {
            Write-Host "yq not found. Please install yq or use an online converter."
            Write-Host "You can install yq from: https://github.com/mikefarah/yq"
        }
    } catch {
        Write-Error "Conversion failed: $_"
    }
}

# Convert both files
ConvertYamlToJson -yamlFile "supplier-api-spec.yaml" -jsonFile "supplier-api-spec.json"
ConvertYamlToJson -yamlFile "home-test-supplier-api.yaml" -jsonFile "home-test-supplier-api.json"
