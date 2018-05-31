using System;
using System.Collections.Generic;
using System.Text;

public class StringUtil
{
    /// <summary>
    /// Byte转换成String
    /// </summary>
    public static string ByteToString(byte[] memory)
    {
		return Encoding.GetEncoding("UTF-8").GetString(memory);
    }

    /// <summary>
    /// String转换成byte[]
    /// </summary>
    public static byte[] StringToByte(string text)
    {
        //Encoding.Default.GetBytes(text);
		return Encoding.GetEncoding("UTF-8").GetBytes(text);
    }

	public static string ConvertToUtf8( string str )
	{
		UTF8Encoding utf8 = new UTF8Encoding();
		Byte[] encodedBytes = utf8.GetBytes( str );
		String decodedString = utf8.GetString( encodedBytes );
		return decodedString;
	}
}
