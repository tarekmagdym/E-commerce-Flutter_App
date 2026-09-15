class Paginated<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int pages;

  Paginated(
      {required this.items,
      required this.page,
      required this.limit,
      required this.total,
      required this.pages});

  Paginated.empty()
      : items = const [],
        page = 0,
        limit = 20,
        total = 0,
        pages = 0;

  bool get hasMore => page < pages;

  Paginated<T> append(Paginated<T> next) => Paginated<T>(
      items: [...items, ...next.items],
      page: next.page,
      limit: next.limit,
      total: next.total,
      pages: next.pages);

  Paginated<T> replaceItem(bool Function(T) test, T item) => Paginated<T>(
      items: items.map((e) => test(e) ? item : e).toList(),
      page: page,
      limit: limit,
      total: total,
      pages: pages);

  Paginated<T> removeWhere(bool Function(T) test) => Paginated<T>(
      items: items.where((e) => !test(e)).toList(),
      page: page,
      limit: limit,
      total: total - 1,
      pages: pages);

  factory Paginated.fromJson(Map<String, dynamic>? json, List<T> items) =>
      Paginated<T>(
        items: items,
        page: json?['page'] ?? 1,
        limit: json?['limit'] ?? items.length,
        total: json?['total'] ?? items.length,
        pages: json?['pages'] ?? 1,
      );
}