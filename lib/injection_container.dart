import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/add_transaction.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Hive ─────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  final userBox = await Hive.openBox<UserModel>('userBox');
  final transactionBox = await Hive.openBox<TransactionModel>('transactionBox');
  final settingsBox = await Hive.openBox('settingsBox');

  sl.registerSingleton<Box<UserModel>>(userBox);
  sl.registerSingleton<Box<TransactionModel>>(transactionBox);
  sl.registerSingleton<Box<dynamic>>(settingsBox, instanceName: 'settings');

  // ─── Auth ─────────────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      userBox: sl(),
      settingsBox: sl(instanceName: 'settings'),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );

  // ─── Transactions ──────────────────────────────────────
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(transactionBox: sl()),
  );

  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  sl.registerFactory(
    () => TransactionBloc(
      getTransactions: sl(),
      addTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );
}
