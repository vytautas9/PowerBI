// Applies refresh policy to each selected table based on the 
// effective date. Refresh policy is applied only when refresh
// policy is enabled on the table

var effectiveDate = new DateTime(2022, 9, 5);

foreach(var table in Selected.Tables) {
    if(table.EnableRefreshPolicy == true){
        table.ApplyRefreshPolicy(effectiveDate);
    }
}