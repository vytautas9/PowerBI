var effectiveDate = new DateTime(2022, 9, 5);

foreach(var table in Selected.Tables) {
    if(table.EnableRefreshPolicy == true){
        table.ApplyRefreshPolicy(effectiveDate);
    }
}