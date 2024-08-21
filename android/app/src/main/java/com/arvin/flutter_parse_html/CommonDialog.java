package com.arvin.flutter_parse_html;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;
public class CommonDialog extends Dialog implements View.OnClickListener{
    private TextView contentTxt;
    private TextView titleTxt;
    private TextView submitTxt;
    private TextView cancelTxt;

    private Context mContext;
    private String content;
    private OnCloseListener listener;
    private String positiveName;
    private String negativeName;
    private String title;
    private int contentColor;
    private int contentSize;
    private boolean showNegative = true;
    private View.OnClickListener positiveOnclick;
    private View.OnClickListener negativeiOnclick;

    public CommonDialog(Context context) {
        super(context,R.style.MyDialog);
        this.mContext = context;
    }

    public CommonDialog(Context context, int themeResId, String content) {
        super(context, themeResId);
        this.mContext = context;
        this.content = content;
    }

    public CommonDialog(Context context, int themeResId, String content, OnCloseListener listener) {
        super(context, themeResId);
        this.mContext = context;
        this.content = content;
        this.listener = listener;
    }

    protected CommonDialog(Context context, boolean cancelable, OnCancelListener cancelListener) {
        super(context, cancelable, cancelListener);
        this.mContext = context;
    }

    public CommonDialog setContentColor(int contentColor) {
        this.contentColor = contentColor;
        return this;
    }

    public CommonDialog setContentSize(int contentSize) {
        this.contentSize = contentSize;
        return this;
    }

    public CommonDialog setListener(OnCloseListener listener) {
        this.listener = listener;
        return this;
    }

    public TextView getContentTxt() {
        return contentTxt;
    }

    public CommonDialog build(){
        setContentView(R.layout.dialog_commom);
        setCanceledOnTouchOutside(false);
        initView();
        return this;
    }

    public TextView getTitleTxt() {
        return titleTxt;
    }

    public CommonDialog setContent(String content) {
        this.content = content;
        if (contentTxt != null){
            contentTxt.setVisibility(TextUtils.isEmpty(content)?View.GONE:View.VISIBLE);
            contentTxt.setText(content);
        }

        return this;
    }

    public CommonDialog setTitle(String title){
        this.title = title;
        return this;
    }

    public CommonDialog setPositiveButton(String name){
        this.positiveName = name;
        return this;
    }

    public CommonDialog setPositiveButton(String name, View.OnClickListener onClickListener){
        this.positiveName = name;
        this.positiveOnclick = onClickListener;
        return this;
    }

    public CommonDialog setNegativeButton(String name){
        this.negativeName = name;
        return this;
    }


    public CommonDialog setNegativeButton(String name, View.OnClickListener onClickListener){
        this.negativeName = name;
        this.negativeiOnclick = onClickListener;
        return this;
    }

    public CommonDialog showNegative(boolean isShow){
        this.showNegative = isShow;
        return this;
    }
    public CommonDialog setNegativeTxtColor(int color){
        if (cancelTxt != null)
            cancelTxt.setTextColor(color);
        return this;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    private void initView(){
        contentTxt = findViewById(R.id.tv_dialog_msg);
        titleTxt = findViewById(R.id.tv_dialog_title);
        submitTxt = findViewById(R.id.tv_confirm);
        submitTxt.setOnClickListener(this);
        cancelTxt = findViewById(R.id.tv_cancel);
        cancelTxt.setOnClickListener(this);
        if (contentColor != 0)
            contentTxt.setTextColor(contentColor);

        if (contentSize != 0)
            contentTxt.setTextSize(contentSize);

        cancelTxt.setVisibility(showNegative?View.VISIBLE:View.GONE);
//        if (!showNegative)
//            submitTxt.setBackground(ContextCompat.getDrawable(getContext(),R.drawable.dialog_btn_confirm_selector));
        contentTxt.setVisibility(TextUtils.isEmpty(content)?View.GONE:View.VISIBLE);
        contentTxt.setText(content);
        if(!TextUtils.isEmpty(positiveName)){
            submitTxt.setText(positiveName);
        }

        if(!TextUtils.isEmpty(negativeName)){
            cancelTxt.setText(negativeName);
        }

        if(!TextUtils.isEmpty(title)){
            titleTxt.setText(title);
            titleTxt.setVisibility(View.VISIBLE);
        }else{
            titleTxt.setVisibility(View.GONE);
        }

    }

    public CommonDialog setCancel(boolean cancelable){
        setCancelable(cancelable);

        return this;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.tv_cancel:
                if(listener != null){
                    listener.onClick(this, false);
                }
                if (negativeiOnclick != null)
                    negativeiOnclick.onClick(v);
                this.dismiss();
                break;
            case R.id.tv_confirm:
                this.dismiss();
                if(listener != null){
                    listener.onClick(this, true);
                }
                if (positiveOnclick != null)
                    positiveOnclick.onClick(v);
                break;
        }
    }

    public interface OnCloseListener{
        void onClick(Dialog dialog, boolean confirm);
    }
}