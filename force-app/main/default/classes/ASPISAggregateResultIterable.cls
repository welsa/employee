global class ASPISAggregateResultIterable implements Iterable<AggregateResult> {
    global Iterator<AggregateResult> Iterator(){
        return new ASPISAggregateResultIterator();
   }
}