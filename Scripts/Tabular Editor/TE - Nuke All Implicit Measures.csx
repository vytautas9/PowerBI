// Disables the default summarization of columns

// Enable the discourage implicit measures option in the model 
Model.DiscourageImplicitMeasures = true;
    
// Sets the summarization by to none 
foreach(var column in Model.Tables.SelectMany(t => t.Columns)) {
    column.SummarizeBy = AggregateFunction.None;
}