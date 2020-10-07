part of 'graph_bloc.dart';

@immutable
abstract class GraphState extends Equatable{
  List<GraphObject> dataList1;
  List<GraphObject> dataList2;

  @override
  List<Object> get props => [];
}

class InitialGraphState extends GraphState {
  final List<GraphObject> dataList1;
  final List<GraphObject> dataList2;


  InitialGraphState(this.dataList1, this.dataList2);

  @override
  List<Object> get props => [dataList1, dataList2];
}

class NewGraphInfo extends GraphState {
 final List<GraphObject> dataList1;
 final List<GraphObject> dataList2;


 NewGraphInfo(this.dataList1, this.dataList2);

 @override
  List<Object> get props => [dataList1, dataList2];
}