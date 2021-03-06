# 利用nginx实现token资源验证

#### 介绍
通过nginx实现对视频、图片、文件下载的token防盗链  
windows：带lua的发行版本（个人推荐`openresty`）  
linux：已编译lua的版本  

#### 注意事项
##### 本教程以及其包含的一切所有人可免费下载，完全开源，开源协议遵照“[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/deed.zh)”，  
[![image](https://github.com/2879597772/ONT/blob/master/images/CC.png)](https://creativecommons.org/licenses/by-sa/4.0/deed.zh)

### 脚本介绍

#### 一 获取当前时间
在nginx的server节中加入以下内容

		location /ts {
		default_type text/html;
		content_by_lua '
		ngx.say((ngx.time() *8) + 4500001316 );
		';
		}

`ngx.say((ngx.time() *8) + 4500001316 );`  
意思是将服务器时间×8之后+4500001316  
可自行修改，但要注意后面也要同步修改  
访问方法：//www.****.com/ts

#### 二 将请求派给lua处理

		location / {
		rewrite_by_lua_file '<lua脚本所在位置>';
            root   <你的请求目录>;
            index  index.html index.htm;
        }

#### 三 lua脚本内容

```
-- 初始化args
local args = nil  

-- 获取get参数  
if "GET" == ngx.var.request_method then  
    args = ngx.req.get_uri_args()  
end  

-- 获取url中的token和ts  
local token = args['token']  
local time = tonumber(args['ts'])  

-- 获取md5值  
function getMd5(time)  
    return ngx.md5((time-4500001316)/8 .. '123456')  
end  
-- 将url获取到的(time-4500001316)/8并在后面加上123456作为混淆  

-- 更新系统缓存时间戳  
ngx.update_time();  
-- 获取当前服务器系统时间，ngx.time() 获取的是秒  
local getTime = ngx.time();  

-- 计算时间差  
 local diffTime = tonumber((time-4500001316)/8) - getTime;  
-- 将url的时间-系统时间  

-- 初始化ur  
local ur = 0;  

-- 验证token是否合法 是否过期  
if time ~= nil and token ~= nil and string.len(token) == 32 and getMd5(time) == token and (tonumber(diffTime)>=-15) and (tonumber(diffTime)<=60) then  
-- 判断/time不能为空 and token不能为空 adn token必须为32位字符 and token的值必须等于getMd5(time)计算出来的值 and 时间差必须大于等于-15 and 时间差必须小于等于60  
ur = 1;  
-- 通过以上条件，ur赋值1
end  

-- 判断
if 0 == ur then  
-- 验证不通过的情况  
ngx.exit(401)  
-- 返回401
end  
-- 因为ur=1，所以通过
```  

#### 四 PHP访问受保护的资源

````
	<?php
	//token加密  
	//获取服务器时间  
		//初始化  
		$curl = curl_init();  
		// 跳过证书检查  
		curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);  
		// 不从证书中检查SSL加密算法是否存在  
		curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);  
		//设置抓取的url  
		curl_setopt($curl, CURLOPT_URL, "https://www.you.com/token/ts");  
		//你的网址"https://www.you.com/token/ts"
		//设置头文件的信息作为数据流输出  
		curl_setopt($curl, CURLOPT_HEADER, 0);  
		//设置获取的信息以文件流的形式返回，而不是直接输出。  
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);  
		//执行命令  
		$data = curl_exec($curl);  
		//关闭URL请求  
		curl_close($curl);  
		//显示获得的数据  
		//print_r($data);  
	//赋值  
	$ts         = $data ;  
	$token_time = (($data-4500001316)/8);//时间戳解密  
	$token      = md5($token_time."123456");//token_md5验证  
	//  
	echo "<img src='//www.you.com/1.jpg?ts=$ts&token=$token'>"  
	?>  
````  

#### 五 js访问受保护的资源
取自hls.js部分，仅供参考  
````
/*  
var newUrl = url + "?ts=" + (Math.round(new Date().getTime()/1000)*8+4500001316).toString() + "&token=" + hex_md5((Math.round(new Date().getTime()/1000)).toString() + '123456');
*/  
````

##### 此项目为本人做m3u8放盗链播放器时所查，依据网上资料进行整合修改
感谢CSDN、Baidu
