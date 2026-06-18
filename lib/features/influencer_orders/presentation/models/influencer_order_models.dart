import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum InfluencerOrderStatus {
  newRequest,
  inProgress,
  pendingClientReview,
  completed,
  declined,
}

enum InfluencerOrdersFilter { all, completed, cancelled, newest, pending }

enum InfluencerOrderDetailTab {
  status,
  client,
  orderDetails,
  attachment,
  financialDetails,
  taxInvoice,
}

extension InfluencerOrderStatusX on InfluencerOrderStatus {
  String get label {
    switch (this) {
      case InfluencerOrderStatus.newRequest:
        return 'New Request ( Pending Approval )';
      case InfluencerOrderStatus.inProgress:
        return 'Approve ( Pending your progress)';
      case InfluencerOrderStatus.pendingClientReview:
        return 'Done (Pending Client Review)';
      case InfluencerOrderStatus.completed:
        return 'Approved ( Completed )';
      case InfluencerOrderStatus.declined:
        return 'Request Declined ( Canceled )';
    }
  }

  Color get color {
    switch (this) {
      case InfluencerOrderStatus.newRequest:
        return const Color(0xFF0B2D5B);
      case InfluencerOrderStatus.inProgress:
        return const Color(0xFF16A6C9);
      case InfluencerOrderStatus.pendingClientReview:
        return const Color(0xFFF59E0B);
      case InfluencerOrderStatus.completed:
        return const Color(0xFF25A85A);
      case InfluencerOrderStatus.declined:
        return const Color(0xFFE11D48);
    }
  }

  int get progressStep {
    switch (this) {
      case InfluencerOrderStatus.newRequest:
      case InfluencerOrderStatus.declined:
        return 1;
      case InfluencerOrderStatus.inProgress:
        return 2;
      case InfluencerOrderStatus.pendingClientReview:
        return 3;
      case InfluencerOrderStatus.completed:
        return 4;
    }
  }
}

extension InfluencerOrdersFilterX on InfluencerOrdersFilter {
  String get label {
    switch (this) {
      case InfluencerOrdersFilter.all:
        return 'All';
      case InfluencerOrdersFilter.completed:
        return 'Completed';
      case InfluencerOrdersFilter.cancelled:
        return 'Cancelled';
      case InfluencerOrdersFilter.newest:
        return 'New';
      case InfluencerOrdersFilter.pending:
        return 'In Progress';
    }
  }
}

extension InfluencerOrderDetailTabX on InfluencerOrderDetailTab {
  String get label {
    switch (this) {
      case InfluencerOrderDetailTab.status:
        return 'Status';
      case InfluencerOrderDetailTab.client:
        return 'Client';
      case InfluencerOrderDetailTab.orderDetails:
        return 'Order details';
      case InfluencerOrderDetailTab.attachment:
        return 'Attachment';
      case InfluencerOrderDetailTab.financialDetails:
        return 'Financial details';
      case InfluencerOrderDetailTab.taxInvoice:
        return 'Tax Invoice';
    }
  }
}

class InfluencerOrder extends Equatable {
  const InfluencerOrder({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    required this.clientSubtitle,
    required this.logoAsset,
    required this.platformName,
    required this.platformIconAsset,
    required this.priceLabel,
    required this.deliveryDateLabel,
    required this.status,
    required this.details,
    required this.attachments,
    required this.financial,
    this.publicationLinks = const <String>[],
  });

  final String id;
  final String orderNumber;
  final String clientName;
  final String clientSubtitle;
  final String logoAsset;
  final String platformName;
  final String platformIconAsset;
  final String priceLabel;
  final String deliveryDateLabel;
  final InfluencerOrderStatus status;
  final InfluencerOrderDetails details;
  final InfluencerOrderAttachments attachments;
  final InfluencerOrderFinancial financial;
  final List<String> publicationLinks;

  InfluencerOrder copyWith({
    InfluencerOrderStatus? status,
    InfluencerOrderAttachments? attachments,
    List<String>? publicationLinks,
  }) {
    return InfluencerOrder(
      id: id,
      orderNumber: orderNumber,
      clientName: clientName,
      clientSubtitle: clientSubtitle,
      logoAsset: logoAsset,
      platformName: platformName,
      platformIconAsset: platformIconAsset,
      priceLabel: priceLabel,
      deliveryDateLabel: deliveryDateLabel,
      status: status ?? this.status,
      details: details,
      attachments: attachments ?? this.attachments,
      financial: financial,
      publicationLinks: publicationLinks ?? this.publicationLinks,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    orderNumber,
    clientName,
    clientSubtitle,
    logoAsset,
    platformName,
    platformIconAsset,
    priceLabel,
    deliveryDateLabel,
    status,
    details,
    attachments,
    financial,
    publicationLinks,
  ];
}

class InfluencerOrderDetails extends Equatable {
  const InfluencerOrderDetails({
    required this.title,
    required this.orderId,
    required this.description,
    required this.clientNotes,
    required this.clientWebsite,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.campaignObjective,
    required this.targetFollowers,
    required this.targetAgeGroup,
    required this.influencerCategory,
    required this.platforms,
  });

  final String title;
  final String orderId;
  final String description;
  final String clientNotes;
  final String clientWebsite;
  final String deliveryDate;
  final String deliveryTime;
  final List<String> campaignObjective;
  final String targetFollowers;
  final String targetAgeGroup;
  final String influencerCategory;
  final List<String> platforms;

  @override
  List<Object?> get props => <Object?>[
    title,
    orderId,
    description,
    clientNotes,
    clientWebsite,
    deliveryDate,
    deliveryTime,
    campaignObjective,
    targetFollowers,
    targetAgeGroup,
    influencerCategory,
    platforms,
  ];
}

class InfluencerOrderAttachments extends Equatable {
  const InfluencerOrderAttachments({
    required this.files,
    required this.links,
    required this.notes,
    this.taxInvoicePath,
  });

  final List<InfluencerOrderFile> files;
  final List<String> links;
  final String notes;
  final String? taxInvoicePath;

  InfluencerOrderAttachments copyWith({
    List<InfluencerOrderFile>? files,
    List<String>? links,
    String? notes,
    String? taxInvoicePath,
  }) {
    return InfluencerOrderAttachments(
      files: files ?? this.files,
      links: links ?? this.links,
      notes: notes ?? this.notes,
      taxInvoicePath: taxInvoicePath ?? this.taxInvoicePath,
    );
  }

  @override
  List<Object?> get props => <Object?>[files, links, notes, taxInvoicePath];
}

class InfluencerOrderFile extends Equatable {
  const InfluencerOrderFile({required this.name, required this.sizeLabel});

  final String name;
  final String sizeLabel;

  @override
  List<Object?> get props => <Object?>[name, sizeLabel];
}

class InfluencerOrderFinancial extends Equatable {
  const InfluencerOrderFinancial({
    required this.platformTotal,
    required this.items,
    required this.totalOrder,
    required this.listingFee,
    required this.totalBeforeVat,
    required this.taxAmount,
    required this.totalWithTax,
    required this.deposit,
    required this.released,
  });

  final String platformTotal;
  final List<InfluencerOrderFinancialItem> items;
  final String totalOrder;
  final String listingFee;
  final String totalBeforeVat;
  final String taxAmount;
  final String totalWithTax;
  final String deposit;
  final String released;

  @override
  List<Object?> get props => <Object?>[
    platformTotal,
    items,
    totalOrder,
    listingFee,
    totalBeforeVat,
    taxAmount,
    totalWithTax,
    deposit,
    released,
  ];
}

class InfluencerOrderFinancialItem extends Equatable {
  const InfluencerOrderFinancialItem({
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final String amount;
  final String icon;

  @override
  List<Object?> get props => <Object?>[label, amount, icon];
}

class InfluencerOrderAdDraft extends Equatable {
  const InfluencerOrderAdDraft({
    this.filePath,
    this.fileName,
    this.links = const <String>['Siti Tirta Dinar'],
    this.notes = '',
  });

  final String? filePath;
  final String? fileName;
  final List<String> links;
  final String notes;

  InfluencerOrderAdDraft copyWith({
    String? filePath,
    String? fileName,
    List<String>? links,
    String? notes,
  }) {
    return InfluencerOrderAdDraft(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      links: links ?? this.links,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => <Object?>[filePath, fileName, links, notes];
}
