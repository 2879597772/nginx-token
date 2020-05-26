# 利用nginx实现token资源验证

#### 介绍
通过nginx实现对视频、图片、文件下载的token防盗链  
windows：带lua的发行版本（个人推荐`openresty/`）  
linux：已编译lua的版本  

#### 注意事项
##### 本教程以及其包含的一切所有人可免费下载，完全开源，开源协议遵照“[CC-BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh)”，  
[![image](https://github.com/2879597772/ONT/blob/master/images/CC.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh)
##### 其意思为“知识共享-署名-非商业性-相同方式共享，即此教程共享，转发必须注明作者本人-不允许以各种方法拿此教程获利，此共享协议对中国大陆有效，受中国法律保护！

### 脚本介绍

#### 一. 获取当前时间
在nginx的server节中加入以下内容

		location /ts {
		default_type text/html;
		content_by_lua '
		ngx.say((ngx.time() *8) + 4500001316 );
		';
		}

