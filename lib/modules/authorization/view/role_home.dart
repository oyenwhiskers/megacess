import 'package:flutter/widgets.dart';

import '../../admin/view/admin_view.dart';
import '../../checker/view/checker_view.dart';
import '../../manager/view/manager_view.dart';
import '../../mandor/view/manager_view.dart' as mandor;
import '../data/model/user_role.dart';

Widget? homeForRole(String role, {String? nickname}) {
  switch (UserRole.normalize(role)) {
    case UserRole.admin:
      return AdminView(adminName: nickname ?? 'Administrator');
    case UserRole.manager:
      return ManagerView(managerName: nickname ?? 'Manager');
    case UserRole.mandor:
      return mandor.ManagerView(managerName: nickname ?? 'Mandor');
    case UserRole.checker:
      return CheckerView(checkerName: nickname ?? 'Checker');
    default:
      return null;
  }
}
