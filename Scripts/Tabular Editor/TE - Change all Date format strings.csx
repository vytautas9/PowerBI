// We will lopp through each column...
foreach(var column in Model.Tables.SelectMany(t => t.Columns)) {
    
    // And if that column DataType is "DateTime" (including both Dates and DateTimes)
    // And if the format string is not "General Date" (which is usually set for DateTime 
    // columns, not for Date columns, we will change the format string
    if(column.DataType == DataType.DateTime && column.FormatString != "General Date"){
        column.FormatString = "dd-mm-yyyy";
    }
}