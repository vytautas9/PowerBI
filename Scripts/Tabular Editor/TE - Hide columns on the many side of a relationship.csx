// Hide columns on the many side of a relationship  

foreach (var r in Model.Relationships)
{
    var c = r.FromColumn.Name;
    var t = r.FromTable.Name;
    Model.Tables[t].Columns[c].IsHidden = true;
}