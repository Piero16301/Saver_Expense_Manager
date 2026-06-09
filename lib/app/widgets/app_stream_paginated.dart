import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class AppStreamPaginated<T> extends StatefulWidget {
  const AppStreamPaginated({
    required this.stream,
    required this.itemBuilder,
    super.key,
  });

  final Stream<List<T>>? Function(int limit) stream;
  final Widget Function(BuildContext, List<T>, int) itemBuilder;

  @override
  State<AppStreamPaginated<T>> createState() => _AppStreamPaginatedState<T>();
}

class _AppStreamPaginatedState<T> extends State<AppStreamPaginated<T>> {
  final ScrollController _scrollController = ScrollController();

  int _limiteActual = getIt<RemoteConfigService>().paginationLimit;
  final int _incremento = getIt<RemoteConfigService>().paginationLimit;
  Stream<List<T>>? _currentStream;
  int _dataLength = 0;

  @override
  void initState() {
    super.initState();
    _currentStream = widget.stream(_limiteActual);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_dataLength >= _limiteActual) {
        setState(() {
          _limiteActual += _incremento;
          _currentStream = widget.stream(_limiteActual);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<T>>(
      stream: _currentStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              l10n.errorLoadingElements,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        _dataLength = data.length;

        if (data.isEmpty) {
          return Center(
            child: Text(
              l10n.elementsNoData,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return widget.itemBuilder(context, data, index);
          },
        );
      },
    );
  }
}
