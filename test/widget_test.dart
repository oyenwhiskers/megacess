import 'package:flutter_test/flutter_test.dart';
import 'package:megacess/modules/admin/view/admin_view.dart';
import 'package:megacess/modules/authorization/view/role_home.dart';
import 'package:megacess/modules/checker/view/checker_view.dart';
import 'package:megacess/modules/manager/view/manager_view.dart';
import 'package:megacess/modules/mandor/view/manager_view.dart' as mandor;

void main() {
  test('all supported roles resolve to their mobile home', () {
    expect(homeForRole('admin'), isA<AdminView>());
    expect(homeForRole('manager'), isA<ManagerView>());
    expect(homeForRole('mandor'), isA<mandor.ManagerView>());
    expect(homeForRole('checker'), isA<CheckerView>());
    expect(homeForRole('unknown'), isNull);
  });
}
