import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vera_clinic/core/theme/app_theme.dart';
import 'package:vera_clinic/features/services/cubit/ServicesCubit.dart';
import '../cubit/invoices_cubit.dart';
import '../widgets/Invoice_List_View.dart';
import '../widgets/invoices_header.dart';
import 'AddInvoicePage.dart';

class InvoicesListPage extends StatefulWidget {
  const InvoicesListPage({super.key});

  @override
  State<InvoicesListPage> createState() => _InvoicesListPageState();
}

class _InvoicesListPageState extends State<InvoicesListPage> {

  bool isArchiveMode = false;
  @override
  void initState() {
    super.initState();
    context.read<InvoicesCubit>().loadInitial();
  }
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

  void _toggleArchiveMode() {
    setState(() {
      isArchiveMode = !isArchiveMode;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InvoicesHeader(
                onAddInvoice: _navigateToAddInvoice,
                onToggleArchiveView: _toggleArchiveMode,
                isArchiveMode: isArchiveMode,
              ),
              Expanded(
                child: InvoiceListView(showArchived: isArchiveMode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
