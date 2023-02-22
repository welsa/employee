/*
  ----------------------------------------------------------------------
  -- - Name          : AggregateResultIterable
  -- - Author        : VSU
  -- - Description   : 
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  --01-JUN-2018    VSU     1.0     Initial version
  
  **********************************************************************
*/
global class AggregateResultIterable implements Iterable<AggregateResult>{ 
    private String query;

    global AggregateResultIterable(String soql){
      query = soql;
    }

    global Iterator<AggregateResult> Iterator(){ 
        return new AggregateResultIterator(query); 
    } 
}