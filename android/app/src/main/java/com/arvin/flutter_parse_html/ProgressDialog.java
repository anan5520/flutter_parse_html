package com.arvin.flutter_parse_html;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.util.TypedValue;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.ldoublem.loadingviewlib.view.LVEatBeans;

import java.lang.ref.WeakReference;


public class ProgressDialog
{
    private  Dialog dialog;
    private  TextView tvDescribe;
    private boolean isOutTime = true;
    private static ProgressDialog progressDialog;
    private Activity mAct;
    private LVEatBeans lvGhost;

    public static ProgressDialog getInstance(){
        if (progressDialog == null)
           return progressDialog = new ProgressDialog();
        return progressDialog;
    }

    public ProgressDialog buildDialog(Activity context)
    {
        if (context != mAct){
            mAct = context;
            dialog = new Dialog(context, R.style.Dialog02);
            dialog.setContentView(R.layout.firset_dialog_view);
            lvGhost = dialog.findViewById(R.id.img_loading);
            lvGhost.startAnim(5000);
            Window window = dialog.getWindow();
            WindowManager.LayoutParams lp = window.getAttributes();

            int screenW = getScreenWidth(context);
            lp.width = (int) (0.8 * screenW);
            lp.height = dp2px(context,80);
            tvDescribe = (TextView) dialog.findViewById(R.id.tvLoad);

            final ProcessOutTime processOutTime = new ProcessOutTime(context,dialog);
            dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
                @Override
                public void onDismiss(DialogInterface dialog) {
                    if (processOutTime!=null && isOutTime)
                        processOutTime.stop();

                    if (lvGhost!=null)
                        lvGhost.stopAnim();

                }
            });
            dialog.setOnShowListener(new DialogInterface.OnShowListener() {
                @Override
                public void onShow(DialogInterface dialog) {
                    if (processOutTime!=null && isOutTime)
                        processOutTime.start();

                    if (lvGhost!=null)
                        lvGhost.startAnim();
                }
            });
        }
        return this;
    }
    public ProgressDialog setDescription(String description)
    {
        tvDescribe.setText(description);
        return this;
    }
    public void show()
    {
        if(dialog != null && !mAct.isFinishing())
        dialog.show();
    }
    public void dismiss()
    {
        try {
            if (dialog != null && !mAct.isFinishing())
                dialog.dismiss();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean isShowing()
    {
        return dialog.isShowing();
    }
    public void setCancelable(boolean cancelable)
    {
        dialog.setCancelable(cancelable);
    }

    public ProgressDialog setOutTime(boolean outTime)
    {
        isOutTime = outTime;
        return this;
    }

    /*超时线程*/
    private static class ProcessOutTime implements Runnable
    {
        private boolean running = false;
        private long startTime = 0L;
        private Thread thread = null;
        private final WeakReference<Activity> mActRef;
        private final WeakReference<Dialog> pDialogRef;

        public ProcessOutTime(Activity mAct,Dialog dialog)
        {
            mActRef = new WeakReference<Activity>(mAct);
            pDialogRef = new WeakReference<Dialog>(dialog);
        }

        public void run()
        {
            while (true)
            {
                if (!this.running)
                    return;
                if (System.currentTimeMillis() - this.startTime > 15 * 1000L)
                {
                    final Activity cAct = mActRef.get();
                    final Dialog pDialog = pDialogRef.get();
                    if (cAct != null)
                    {
                        cAct.runOnUiThread(new Runnable()
                        {
                            @Override
                            public void run()
                            {
                                if (pDialog != null && pDialog.isShowing())
                                {
                                    pDialog.dismiss();
//									ToastUtils.showShort(cAct.mAct, "程序出现了不可抗拒的错误，关闭页面重试下...");
                                }
                            }
                        });
                    }
                    this.running = false;
                    this.thread = null;
                    this.startTime = 0L;
                }
                try
                {
                    Thread.sleep(200L);
                } catch (Exception localException)
                {
                }
            }
        }

        public void start()
        {
            try
            {
                this.thread = new Thread(this);
                this.running = true;
                this.startTime = System.currentTimeMillis();
                this.thread.start();
            } catch (Exception e)
            {
            } finally
            {
            }
        }

        public void stop()
        {
            this.running = false;
            this.thread = null;
            this.startTime = 0L;
        }
    }

    /**
     * 得到设备屏幕的高度
     */
    public static int getScreenHeight(Context context)
    {
        return context.getResources().getDisplayMetrics().heightPixels;
    }

    /**
     * 得到设备屏幕的宽度
     */
    public static int getScreenWidth(Context context)
    {
        return context.getResources().getDisplayMetrics().widthPixels;
    }

    /**
     * dp转px
     *
     * @param context
     * @param dp
     * @return
     */
    public static int dp2px(Context context, float dp)
    {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                dp,
                context.getResources().getDisplayMetrics());
    }


}
