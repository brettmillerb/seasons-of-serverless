using namespace System.Net

# Input bindings are passed in via param block.
param (
    $Request,
    $TriggerMetadata
)

# Check for the existence of the query string or body
$turkeyWeight = $Request.Query.weight
if (-not $turkeyWeight) {
    $turkeyWeight = $Request.Body.weight
}

if (-not $turkeyWeight) {
    Push-OutputBinding -Name Response -Value (
        [HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::BadRequest
            Body       = 'Please pass a weight for the turkey you want to calculate'
        }
    )
}
else {
    $ingredients = [ordered]@{
        salt           = @{unit = 'cups'; quantity = 0.05}
        water          = @{unit = 'gallons'; quantity = 0.66}
        brownSugar     = @{unit = 'cups'; quantity = 0.13}
        shallots       = @{unit = 'cups'; quantity = 0.2}
        garlic         = @{unit = 'cloves'; quantity = 0.4}
        peppercorns    = @{unit = 'tablespoons'; quantity = 0.13}
        juniperBerries = @{unit = 'tablespoons'; quantity = 0.13}
        rosemary       = @{unit = 'tablespoons'; quantity = 0.13}
        thyme          = @{unit = 'tablespoons'; quantity = 0.06}
        brineTime      = @{unit = 'hours'; quantity = 2.4}
        roastTime      = @{unit = 'minutes'; quantity = 15}
    }
    
    $calculatedIngredients = $ingredients.GetEnumerator() | ForEach-Object {
        '{0} {1} of {2}' -f ([math]::round($_.Value.quantity * $turkeyWeight)), $_.Value.unit, $_.key
    }
    
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $calculatedIngredients
    })
}
