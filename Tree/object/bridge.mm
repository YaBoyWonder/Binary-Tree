include "scripting/lua-bindings/manual/platform/ios/CCLuaObjcBridge.h"
#include <Foundation/Foundation.h>

NS_CC_BEGIN

void LuaObjcBridge::luaopen_luaoc(lua_State *L)
{
    s_luaState = L;
    lua_newtable(L);
    lua_pushstring(L, "callStaticMethod");
    lua_pushcfunction(L, LuaObjcBridge::callObjcStaticMethod);
    lua_rawset(L, -3);
    lua_setglobal(L, "LuaObjcBridge");
}

/**
 className
 methodName
 args
 */
int LuaObjcBridge::callObjcStaticMethod(lua_State *L)
{
    if (lua_gettop(L) != 3 || !lua_isstring(L, -3) || !lua_isstring(L, -2))
    {
    	lua_pushboolean(L, 0);
    	lua_pushinteger(L, kLuaBridgeErrorInvalidParameters);
    	return 2;
    }
    
    const char *className  = lua_tostring(L, -3);
    const char *methodName = lua_tostring(L, -2);
    if (!className || !methodName)
    {
        lua_pushboolean(L, 0);
        lua_pushinteger(L, kLuaBridgeErrorInvalidParameters);
        return 2;
    }
    
    Class targetClass = NSClassFromString([NSString stringWithCString:className encoding:NSUTF8StringEncoding]);
    if (!targetClass)
    {
        lua_pushboolean(L, 0);
        lua_pushinteger(L, kLuaBridgeErrorClassNotFound);
        return 2;
    }
    
    SEL methodSel;
    bool hasArguments = lua_istable(L, -1);
    if (hasArguments)
    {
        NSString *methodName_ = [NSString stringWithCString:methodName encoding:NSUTF8StringEncoding];
        methodName_ = [NSString stringWithFormat:@"%@:", methodName_];
        methodSel = NSSelectorFromString(methodName_);
    }
    else
    {
        methodSel = NSSelectorFromString([NSString stringWithCString:methodName encoding:NSUTF8StringEncoding]);
    }
    if (methodSel == (SEL)0)
    {
        lua_pushboolean(L, 0);
        lua_pushinteger(L, kLuaBridgeErrorMethodNotFound);
        return 2;
    }
    
    NSMethodSignature *methodSig = [targetClass methodSignatureForSelector:(SEL)methodSel];
    if (methodSig == nil)
    {
        lua_pushboolean(L, 0);
        lua_pushinteger(L, kLuaBridgeErrorMethodSignature);
        return 2;
    }
    
    @try {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setTarget:targetClass];
        [invocation setSelector:methodSel];
        NSUInteger returnLength = [methodSig methodReturnLength];
        const char *returnType = [methodSig methodReturnType];
        
    
   
