import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vera_clinic/core/theme/app_theme.dart';
import 'package:vera_clinic/features/services/cubit/ServicesCubit.dart';
import '../cubit/invoices_cubit.dart';
import '../widgets/Invoice_List_View.dart';
import '../widgets/invoices_header.dart';
import 'AddInvoicePage.dart';

class InvoicesListPage extends StatelessWidget {
  const InvoicesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    void _navigateToAddInvoice() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ServicesCubit>(),
            child: BlocProvider.value(
              value: context.read<InvoicesCubit>(),
              child: const AddInvoicePage(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InvoicesHeader(onAddInvoice: _navigateToAddInvoice),
              const Expanded(child: InvoiceListView()),
            ],
          ),
        ),
      ),
    );
  }
}
