// Hide columns on the many side of a relationship  

foreach (var r in Model.Relationships)
{
    // apply only if the direction is one way and relationship is active
    if (r.CrossFilteringBehavior.ToString() == "OneDirection" & r.IsActive == true)
    {
        // hide all columns on the many side of a join
        var c = r.FromColumn.Name;
        var t = r.FromTable.Name;
        Model.Tables[t].Columns[c].IsHidden = true; 
    }
}