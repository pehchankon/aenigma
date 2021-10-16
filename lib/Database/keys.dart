class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}

class Keys
{
  List<Pair<String,String>> _list = [Pair('key','value')];

  void add(String key, String value)
  {
    _list.add(Pair(key,value));
  }
  List get()
  {
    return _list;
  }

}