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