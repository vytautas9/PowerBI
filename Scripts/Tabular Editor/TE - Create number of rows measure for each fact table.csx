// Creates a measure for each fact table which counts the number of rows,
// puts this measure in a dispaly folder and hides it.

// measure name template. {0} - table name
var measureNameTemplate = "# rows - {0}";

// loop through each of the table
foreach(var table in Model.Tables) {
    var tableName = table.Name;
    
    // if table name does not starts with fact, skip to the next table
    if(!tableName.StartsWith("fact_"))
    {
        continue;
    }
    
    var newMeasureName = "";
    var indexOfMeasure = 0;
    var listOfMeasures = new List<string>();
    
    // loop through each of the measure in the table and save them in list
    foreach(var measure in table.Measures){
        listOfMeasures.Add( measure.Name );
    }
    
    newMeasureName = String.Format( measureNameTemplate, tableName );
    indexOfMeasure = listOfMeasures.IndexOf( newMeasureName );
    
    // if such measure does not exist, create one
    if(newMeasureName != "" && indexOfMeasure == -1)
    {
        var newMeasure = table.AddMeasure
        (
            newMeasureName,
            " COUNTROWS ( " + tableName + " )",
            "general"
        );
        
        newMeasure.FormatString = "#,0";
        newMeasure.IsHidden = true;
    }

}