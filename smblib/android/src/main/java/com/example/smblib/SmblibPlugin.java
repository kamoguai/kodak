package com.example.smblib;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.ExpandableListView;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Properties;
import java.util.concurrent.TimeUnit;

import androidx.annotation.NonNull;

import androidx.annotation.Nullable;
import androidx.loader.content.AsyncTaskLoader;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import jcifs.CIFSContext;
import jcifs.CIFSException;
import jcifs.Configuration;
import jcifs.config.PropertyConfiguration;
import jcifs.context.BaseContext;
import jcifs.smb.NtlmPasswordAuthenticator;
import jcifs.smb.SmbFile;
import jcifs.smb.SmbFileOutputStream;

//import com.hierynomus.smbj.SMBClient;
//import com.hierynomus.smbj.SmbConfig;
//import com.hierynomus.smbj.auth.AuthenticationContext;
//import com.hierynomus.smbj.connection.Connection;
//import com.hierynomus.smbj.session.Session;


/** SmblibPlugin */
public class SmblibPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static String _hostName = "";
  private static String _userName = "";
  private static String _password = "";
  private static String _domain = "";

//  private static NtlmPasswordAuthentication _auth = null;
  private static NtlmPasswordAuthenticator _auth2 = null;
//  private static AuthenticationContext _auth3 = null;
  private static int _callSmb = 1;
  private static CIFSContext _baseCxt = null;
  private static CIFSContext _ct = null;


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "smblib");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//    if(call.method.equals("getPlatformVersion")) {
//      result.success("Android " + android.os.Build.VERSION.RELEASE);
//    }
//    else {
//      result.notImplemented();
//    }
    Log.d("methodHandler","call method: " + call.method );
    switch (call.method){
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "Login":
        /**
         * 檢驗登入是否成功
         * @param hostName   遠端路徑
         * @param username   登入者名稱
         * @param password   登入者帳號
         * @return  true:成功 false:失敗
         */
        if(call.arguments == null) {
          result.error("PARAM_ERROR", "Illegal parameter", null);
        }
        String path = call.argument("hostName");
        String uname = call.argument("userName");
        String pwd = call.argument("password");
        Log.d("methodHandler","hosname1:" + path);
        Log.d("methodHandler","username2:" + uname);
        Log.d("methodHandler","password3:" + pwd);

        if (path.isEmpty()) {
          result.error("PARAM_ERROR", "Illegal hostName", null);
        }
        if(uname.isEmpty()) {
          result.error("PARAM_ERROR", "Illegal username", null);
        }
        if(pwd.isEmpty()) {
          result.error("PARAM_ERROR", "Illegal password", null);
        }

        String[] loginParam = {path,uname,pwd};
        ///run async
        new AsyncTask<String,String,String>() {
          @Override
          protected String doInBackground(String... params) {
            String loginStr = "";
            String host = params[0];
            String user = params[1];
            String pwd = params[2];
            try{
              loginStr =  Login2(host,user,pwd);
            }catch (Exception e) {
              loginStr = e.getMessage();
            }
            return loginStr;
          }

          @Override
          protected void onPostExecute(String res) {
              Log.d("api","login onPress -> " + res);

              result.success(res);

          }
        }.execute(loginParam);

        break;
      case "demo":
        result.success("show hello");
        break;
      case "GetFileList":
        /**
         * 取的資料夾表
         */

        new AsyncTask<String,String,String>() {
          @Override
          protected String doInBackground(String... params) {
            return GetFileList2().toString();
          }

          @Override
          protected void onPostExecute(String res) {
            Log.d("api","getlist onPress -> " + res);

            result.success(res.toString());

          }
        }.execute();

        break;
      case "GetFilePath":
        /**
         * 取的資料夾表for path
         */
        String filePath = call.argument("path");
        String[] filePathParam = {filePath};
        new AsyncTask<String,String,String>() {
          @Override
          protected String doInBackground(String... params) {
            String path = params[0].toString();
            return GetFileList2(path).toString();
          }

          @Override
          protected void onPostExecute(String res) {
            Log.d("api","getlist onPress -> " + res);

            result.success(res.toString());

          }
        }.execute(filePathParam);

        break;
      case "UploadFile":
        /**
         * 上傳本地文件到Samba服務器指定目錄
         * @param url
         * @param auth
         * @param localFilePath
         * @throws MalformedURLException
         * @throws SmbException
         */
        String postUrl = call.argument("url");
        String localPath = call.argument("localFilePath");
        String[] fileUplpadPath = {postUrl,localPath};
        new AsyncTask<String,String,String>() {
          @Override
          protected String doInBackground(String... params) {
            String url = params[0].toString();
            String localFilePath = params[1].toString();

            Log.d("smbApi","smbApi url:" + url);
            Log.d("smbApi","smbApi localFilePath:" + localFilePath);
            Log.d("smbApi","smbApi _hostName:" + _hostName);
            Log.d("smbApi","smbApi _username:" + _userName);
            Log.d("smbApi","smbApi _password:" + _password);
//            NtlmPasswordAuthentication auth = new NtlmPasswordAuthentication(_hostName, _userName, _password);
            try {
              uploadFileToSamba2(url,  localFilePath);
            } catch (MalformedURLException e) {
              e.printStackTrace();
              return "-1";
            } catch (CIFSException e) {
              e.printStackTrace();
              return "-1";
            }
            return "1";
          }

          @Override
          protected void onPostExecute(String res) {
            Log.d("api","upload onPress -> " + res);

            result.success(res);

          }
        }.execute(fileUplpadPath);
        break;
      case "Addfolder":
        String addFurl = call.argument("url");
        String[] addFparam = {addFurl};

        new AsyncTask<String,String,String>() {
          @Override
          protected String doInBackground(String... params) {
            String url = params[0].toString();
            Log.d("api","add folder  url -> " + url);
            try {
              addFolderToSamba2(url);
            } catch (MalformedURLException e) {
              e.printStackTrace();
              return "-1";
            }  catch (CIFSException e) {
              e.printStackTrace();
              return "-1";
            }
            return "1";
          }

          @Override
          protected void onPostExecute(String res) {
            Log.d("api","addfolder onPress -> " + res);

            result.success(res);

          }
        }.execute(addFparam);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public interface AsyncTaskResult<T extends Object>
  {
    // T是執行結果的物件型態

    public void taskFinish( T result );
  }

//  public static boolean addFolderToSamba(String url, NtlmPasswordAuthentication auth) throws MalformedURLException, SmbException {
//     boolean isOk = false;
//    //檢查遠程父路徑，不存在則創建
//    SmbFile remoteSmbFile = new SmbFile(url, auth);
//    Log.d("api","open smbFile");
//    String parent = remoteSmbFile.getParent();
//    Log.d("api","smbFile parent: " + parent);
//    SmbFile parentSmbFile = new SmbFile(parent, auth);
//    Log.d("api","open smbFile parent");
//    if (parentSmbFile.exists()) {
//      Log.d("api", "判斷資料夾存在: " + parentSmbFile.exists());
//      remoteSmbFile.mkdirs();
//      isOk = true;
//    }
//    return isOk;
//  }

  public static boolean addFolderToSamba2(String url) throws MalformedURLException, CIFSException {
    boolean isOk = false;

    //檢查遠程父路徑，不存在則創建
    SmbFile remoteSmbFile = new SmbFile(url, _ct);
    Log.d("api","open smbFile");
    String parent = remoteSmbFile.getParent();
    Log.d("api","smbFile parent: " + parent);
    SmbFile parentSmbFile = new SmbFile(parent, _ct);
    Log.d("api","open smbFile parent");
    if (parentSmbFile.exists()) {
      Log.d("api", "判斷資料夾存在: " + parentSmbFile.exists());
      remoteSmbFile.mkdirs();
      isOk = true;
    }
    return isOk;
  }
  /**
   * 上傳本地文件到Samba服務器指定目錄
   * @param url
   * @param auth
   * @param localFilePath
   * @throws MalformedURLException
   * @throws SmbException
   */
//  public static void uploadFileToSamba(String url, NtlmPasswordAuthentication auth, String localFilePath) throws MalformedURLException, SmbException {
//    if ((localFilePath == null) || ("".equals(localFilePath.trim()))) {
//      System.out.println("本地文件路徑不可以爲空");
//      return;
//    }
//    Log.d("api","start file upload");
//    //檢查遠程父路徑，不存在則創建
//    SmbFile remoteSmbFile = new SmbFile(url, auth);
//    Log.d("api","open smbFile");
//    String parent = remoteSmbFile.getParent();
//    Log.d("api","smbFile parent: " + parent);
//    SmbFile parentSmbFile = new SmbFile(parent, auth);
//    Log.d("api","open smbFile parent");
//
//    if (!parentSmbFile.exists()) {
//      Log.d("api","判斷資料夾存在: " + !parentSmbFile.exists());
//      parentSmbFile.mkdirs();
//    }
//
//    InputStream in = null;
//    OutputStream out = null;
//
//    try{
//      File localFile = new File(localFilePath);
//      Log.d("api","open localfile: " + localFile.isFile());
//      if(!localFile.isFile()) {
//        Log.d("api","no such local file");
//      }
//      //打開一個文件輸入流執行本地文件，要從它讀取內容
//      in = new BufferedInputStream(new FileInputStream(localFile));
//      Log.d("api","open inputstream");
//      Log.d("api","open remoteSmbFile: " + remoteSmbFile);
//      //打開一個遠程Samba文件輸出流，作爲複製到的目的地
//      out = new BufferedOutputStream(new SmbFileOutputStream(remoteSmbFile));
//      Log.d("api","open outputstream");
//
//      //緩衝內存
//      byte [] buffer =  new   byte [1024];
//      Log.d("api","open buffer byte");
//      while  (in.read(buffer) != - 1 ) {
//        out.write(buffer);
//        buffer = new byte[1024];
//      }
//      Log.d("api","out write");
//
//    } catch  (Exception e) {
//      e.printStackTrace();
//
//    } finally  {
//      try  {
//        out.close();
//        in.close();
//      } catch  (IOException e) {
//        e.printStackTrace();
//      }
//    }
//  }

  /**
   * 上傳本地文件到Samba服務器指定目錄
   * @param url
   * @param localFilePath
   * @throws MalformedURLException
   * @throws CIFSException
   */
  public static void uploadFileToSamba2(String url, String localFilePath) throws MalformedURLException, CIFSException {
    if ((localFilePath == null) || ("".equals(localFilePath.trim()))) {
      System.out.println("本地文件路徑不可以爲空");
      return;
    }
    Log.d("api","start file upload");

    //檢查遠程父路徑，不存在則創建
    SmbFile remoteSmbFile = new SmbFile(url, _ct);
    Log.d("api","open smbFile");
    String parent = remoteSmbFile.getParent();
    Log.d("api","smbFile parent: " + parent);
    SmbFile parentSmbFile = new SmbFile(parent, _ct);
    Log.d("api","open smbFile parent");

    if (!parentSmbFile.exists()) {
      Log.d("api","判斷資料夾存在: " + !parentSmbFile.exists());
      parentSmbFile.mkdirs();
    }

    InputStream in = null;
    OutputStream out = null;

    try{
      File localFile = new File(localFilePath);
      Log.d("api","open localfile: " + localFile.isFile());
      if(!localFile.isFile()) {
        Log.d("api","no such local file");
      }
      //打開一個文件輸入流執行本地文件，要從它讀取內容
      in = new BufferedInputStream(new FileInputStream(localFile));
      Log.d("api","open inputstream");
      Log.d("api","open remoteSmbFile: " + remoteSmbFile);
      //打開一個遠程Samba文件輸出流，作爲複製到的目的地
      out = new BufferedOutputStream(new SmbFileOutputStream(remoteSmbFile));
      Log.d("api","open outputstream");

      //緩衝內存
      byte [] buffer =  new   byte [1024];
      Log.d("api","open buffer byte");
      while  (in.read(buffer) != - 1 ) {
        out.write(buffer);
        buffer = new byte[1024];
      }
      Log.d("api","out write");

    } catch  (Exception e) {
      e.printStackTrace();

    } finally  {
      try  {
        out.close();
        in.close();
      } catch  (IOException e) {
        e.printStackTrace();
      }
    }
  }



  /**
   * 檢驗登入是否成功
   * @param hostName   遠端路徑
   * @param username   登入者名稱
   * @param password   登入者帳號
   * @return  true:成功 false:失敗
   */
//  public static String Login(String hostName, String username, String password) {
//    String result = "ok";
//    try{
//      Log.d("smbApi","smbApi hostName:" + hostName);
//      Log.d("smbApi","smbApi username:" + username);
//      Log.d("smbApi","smbApi password:" + password);
//      _hostName = hostName;
//      _userName = username;
//      _password = password;
//      UniAddress ua = UniAddress.getByName(hostName);
//      Log.d("smbApi","[pass hostname]");
//      NtlmPasswordAuthentication auth = new NtlmPasswordAuthentication(hostName, username, password);
//      Log.d("smbApi","[pass auth]");
//      SmbSession.logon(ua, auth);
//      _auth = auth;
//      result = "ok";
//      Log.d("smbApi","smb login success");
//    }catch (Exception e) {
//      result = e.getMessage();
//      Log.d("smbApi","smb login fails: " + e.getMessage());
//    }
//    return result;
//  }

  /**
   * 檢驗登入是否成功
   * @param hostName   遠端路徑
   * @param username   登入者名稱
   * @param password   登入者帳號
   * @return  true:成功 false:失敗
   */
  public static String Login2(String hostName, String username, String password) {
    String result = "ok";
    try{
      Log.d("smbApi2","smbApi2 hostName:" + hostName);
      Log.d("smbApi2","smbApi2 username:" + username);
      Log.d("smbApi2","smbApi2 password:" + password);
      _hostName = hostName;
      _userName = username;
      _password = password;

      Properties jcifsProperties  = new Properties();
      jcifsProperties.setProperty("jcifs.smb.client.enableSMB2", "true");
      jcifsProperties.setProperty("jcifs.smb.client.dfs.disabled","true");
      Configuration config = new PropertyConfiguration(jcifsProperties);
      CIFSContext baseCxt = new BaseContext(config);
      Log.d("smbApi2","[pass hostname]");
      NtlmPasswordAuthenticator auth = new NtlmPasswordAuthenticator(hostName,username, password);
      CIFSContext ct = baseCxt.withCredentials(auth);
      Log.d("smbApi2","[pass auth]");
      /// 驗證是否連到folder
      String remoteUrl = "smb://" + _hostName ;
      SmbFile dir = new SmbFile(remoteUrl, ct);
      ///如果出錯就catch出去
      int len = dir.listFiles().length;


      _auth2 = auth;
      _baseCxt = baseCxt;
      _ct = ct;
      result = "ok";
      Log.d("smbApi2","smb2 login success");
    }catch (Exception e) {
      result = e.getMessage();
      Log.d("smbApi2","smb2 login fails: " + e.getMessage());
    }
    return result;
  }
/*
    public static String Login3(String hostName, String username, String password) {
    String result = "ok";
    try{
      Log.d("smbApi","smbApi hostName:" + hostName);
      Log.d("smbApi","smbApi username:" + username);
      Log.d("smbApi","smbApi password:" + password);
      _hostName = hostName;
      _userName = username;
      _password = password;

      // 設定超時時間(可選)
      SmbConfig config = SmbConfig.builder().withTimeout(120, TimeUnit.SECONDS)
              .withTimeout(120, TimeUnit.SECONDS) // 超時設定讀，寫和Transact超時（預設為60秒）
              .withSoTimeout(180, TimeUnit.SECONDS) // Socket超時（預設為0秒）
              .build();

      // 如果不設定超時時間	SMBClient client = new SMBClient();
      SMBClient client = new SMBClient(config);
      Connection connection = client.connect(_hostName);
      Log.d("smbApi","[pass hostname]");
      if(_userName.contains("\\")) {
        _domain = _userName.substring(0,_userName.indexOf("\\") + 1);
      }
      AuthenticationContext auth = new AuthenticationContext(_userName, _password.toCharArray(), _domain);
      Log.d("smbApi","[pass auth]");
      Session session = connection.authenticate(auth);
      _auth3 = auth;
      result = "ok";
      Log.d("smbApi","smb login success");
    }catch (Exception e) {
      result = e.getMessage();
      Log.d("smbApi","smb login fails: " + e.getMessage());
    }
    return result;
  }

 */


//  public static ArrayList GetFileList() {
//    ArrayList fileList = new ArrayList();
//    try {
//      String remoteUrl = "smb://" + _hostName ;
//      Log.d("smbApi","smbApi GetFileList: " + remoteUrl);
//      SmbFile dir = new SmbFile(remoteUrl, _auth);
//
//      for (SmbFile f : dir.listFiles())
//      {
//        System.out.println(f.getName());
//
//        if(f.getName().contains("$")) {
//          continue;
//        }
//        fileList.add(f.getName());
//      }
//      Log.d("smbApi","smbApi GetFileList: " + fileList.toString());
//      return fileList;
//    }catch (Exception e) {
//      Log.d("smbApi","smbApi fileList err");
//      return fileList;
//    }
//  }

  public static ArrayList GetFileList2() {
    ArrayList fileList = new ArrayList();
    try {
      String remoteUrl = "smb://" + _hostName ;
      Log.d("smbApi2","smbApi2 GetFileList: " + remoteUrl);

      Log.d("smbApi2","smbApi2 auth ct " + remoteUrl);
      SmbFile dir = new SmbFile(remoteUrl, _ct);
      Log.d("smbApi2","smbApi2 GetFileList dir: " + dir.getPath());

      for (SmbFile f : dir.listFiles())
      {
        Log.d("smbApi2","smbApi2 GetFileList f.getName: " + f.getName());

        if(f.getName().contains("$")) {
          continue;
        }
        fileList.add(f.getName());
      }
      Log.d("smbApi2","smbApi2 GetFileList: " + fileList.toString());
      return fileList;
    }catch (Exception e) {
      Log.d("smbApi2","smbApi2 fileList err");
      return fileList;
    }
  }
//  public static ArrayList GetFileList(String path) {
//    ArrayList fileList = new ArrayList();
//    try {
//      String remoteUrl = "smb://" + _hostName + "/" + path;
//      Log.d("smbApi","smbApi GetFileList: " + remoteUrl);
//      SmbFile dir = new SmbFile(remoteUrl, _auth);
//
//      for (SmbFile f : dir.listFiles())
//      {
//        System.out.println(f.getName());
//
//        if(f.getName().contains("$")) {
//          continue;
//        }
//        fileList.add(f.getName());
//      }
//      Log.d("smbApi","smbApi GetFileList: " + fileList.toString());
//      return fileList;
//    }catch (Exception e) {
//      Log.d("smbApi","smbApi fileList err");
//      return fileList;
//    }
//  }
  public static ArrayList GetFileList2(String path) {
    ArrayList fileList = new ArrayList();
    try {
      String remoteUrl = "smb://" + _hostName + "/" + path;
      Log.d("smbApi","smbApi GetFileList: " + remoteUrl);

      SmbFile dir = new SmbFile(remoteUrl, _ct);

      for (SmbFile f : dir.listFiles())
      {
        System.out.println(f.getName());

        if(f.getName().contains("$")) {
          continue;
        }
        fileList.add(f.getName());
      }
      Log.d("smbApi","smbApi GetFileList: " + fileList.toString());
      return fileList;
    }catch (Exception e) {
      Log.d("smbApi","smbApi fileList err");
      return fileList;
    }
  }
}





















