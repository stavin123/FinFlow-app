import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final DeleteTransaction deleteTransaction;

  TransactionBloc({
    required this.getTransactions,
    required this.addTransaction,
    required this.deleteTransaction,
  }) : super(TransactionInitial()) {
    on<TransactionLoadRequested>(_onLoad);
    on<TransactionAddRequested>(_onAdd);
    on<TransactionDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTransactions(event.userId);
    result.fold(
      (f) => emit(TransactionError(f.message)),
      (list) => emit(TransactionLoaded(list)),
    );
  }

  Future<void> _onAdd(
    TransactionAddRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await addTransaction(event.transaction);
    result.fold(
      (f) => emit(TransactionError(f.message)),
      (_) {
        if (state is TransactionLoaded) {
          final current = (state as TransactionLoaded).transactions;
          final updated = [event.transaction, ...current]
            ..sort((a, b) => b.date.compareTo(a.date));
          emit(TransactionLoaded(updated));
        }
      },
    );
  }

  Future<void> _onDelete(
    TransactionDeleteRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransaction(event.id);
    result.fold(
      (f) => emit(TransactionError(f.message)),
      (_) {
        if (state is TransactionLoaded) {
          final current = (state as TransactionLoaded).transactions;
          emit(TransactionLoaded(
              current.where((t) => t.id != event.id).toList()));
        }
      },
    );
  }
}
