﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class NetworkManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(NetworkManager), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("Init", Init);
		L.RegFunction("AddEvent", AddEvent);
		L.RegFunction("SendConnect", SendConnect);
		L.RegFunction("Send", Send);
		L.RegFunction("HttpGet", HttpGet);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("instance", get_instance, set_instance);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Init(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			NetworkManager obj = (NetworkManager)ToLua.CheckObject<NetworkManager>(L, 1);
			obj.Init();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddEvent(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 1);
			byte[] arg1 = ToLua.CheckByteBuffer(L, 2);
			NetworkManager.AddEvent(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendConnect(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			NetworkManager obj = (NetworkManager)ToLua.CheckObject<NetworkManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
			obj.SendConnect(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Send(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			NetworkManager obj = (NetworkManager)ToLua.CheckObject<NetworkManager>(L, 1);
			LuaByteBuffer arg0 = new LuaByteBuffer(ToLua.CheckByteBuffer(L, 2));
			obj.Send(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpGet(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			NetworkManager obj = (NetworkManager)ToLua.CheckObject<NetworkManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.HttpGet(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_instance(IntPtr L)
	{
		try
		{
			ToLua.Push(L, NetworkManager.instance);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_instance(IntPtr L)
	{
		try
		{
			NetworkManager arg0 = (NetworkManager)ToLua.CheckObject<NetworkManager>(L, 2);
			NetworkManager.instance = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

