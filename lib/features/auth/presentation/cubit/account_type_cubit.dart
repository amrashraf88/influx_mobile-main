import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AccountTypeOption { influencer, company }

class AccountTypeState extends Equatable {
  const AccountTypeState(this.selected);

  final AccountTypeOption selected;

  @override
  List<Object?> get props => <Object?>[selected];
}

class AccountTypeCubit extends Cubit<AccountTypeState> {
  AccountTypeCubit()
      : super(const AccountTypeState(AccountTypeOption.influencer));

  void select(AccountTypeOption option) {
    if (state.selected == option) return;
    emit(AccountTypeState(option));
  }
}
