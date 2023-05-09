import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../srun/result.dart';
import '../utils/utils.dart';

class Status extends StatelessWidget {
  const Status({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>();
    return Container(
      width: 150.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Selector<UserProvider, Result?>(
        builder: (context, value, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '登录成功',
              style: TextStyle(fontSize: 15.sp),
            ),
            Text('用户名：${value!.username}'),
            Text('IP地址：${value.clientIp}'),
            const Divider(),
            ElevatedButton(
              onPressed: () {
                user.srun.logout().then((value) {
                  if (value != null && value.isSuccess) {
                    user.isLogin = false;
                    Utils.showToast('注销成功');
                  } else {
                    Utils.showToast('注销失败');
                  }
                });
              },
              child: const Text('注销登录'),
            )
          ],
        ),
        selector: (p0, p1) => p1.result,
      ),
    );
  }
}
