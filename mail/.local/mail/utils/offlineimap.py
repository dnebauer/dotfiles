# ~/.local/mail/utils/offlineimap.py

# pyright: reportMissingParameterType=false
# pyright: reportUnknownArgumentType=false
# pyright: reportUnknownParameterType=false
# pyright: reportUnknownVariableType=false

# offlineimap pythonfile

""" Convert utf-7 imap directory names to utf-8

Source: https://crazycmd.blogspot.com/2011/11/enable-utf8-for-offlineimap.html

Imap folder names are encoded using a special version of utf-7 as defined in
RFC 2060 section 5.1.3:

5.1.3. Mailbox International Naming Convention

By convention, international mailbox names are specified using a modified
version of the UTF-7 encoding described in [UTF-7]. The purpose of these
modifications is to correct the following problems with UTF-7:

1) UTF-7 uses the "+" character for shifting; this conflicts with the common
   use of "+" in mailbox names, in particular USENET newsgroup names.

2) UTF-7's encoding is BASE64 which uses the "/" character; this conflicts with
   the use of "/" as a popular hierarchy delimiter.

3) UTF-7 prohibits the unencoded usage of "\"; this conflicts with the use of
   "\" as a popular hierarchy delimiter.

4) UTF-7 prohibits the unencoded usage of "~"; this conflicts with the use of
   "~" in some servers as a home directory indicator.

5) UTF-7 permits multiple alternate forms to represent the same string; in
   particular, printable US-ASCII chararacters can be represented in encoded
   form.

In modified UTF-7, printable US-ASCII characters except for "&" represent
themselves; that is, characters with octet values 0x20-0x25 and 0x27-0x7e. The
character "&" (0x26) is represented by the two-octet sequence "&-".

All other characters (octet values 0x00-0x1f, 0x7f-0xff, and all Unicode 16-bit
octets) are represented in modified BASE64, with a further modification from
[UTF-7] that "," is used instead of "/". Modified BASE64 MUST NOT be used to
represent any printing US-ASCII character which can represent itself.

"&" is used to shift to modified BASE64 and "-" to shift back to US-ASCII.
All names start in US-ASCII, and MUST end in US-ASCII (that is, a name that
ends with a Unicode 16-bit octet MUST end with a "-").

For example, here is a mailbox name which mixes English, Japanese, and Chinese
text: ~peter/mail/&ZeVnLIqe-/&U,BTFw-

The function 'convert_utf7_to_utf8' is used by this line in the configuration
file:

  nametrans = lambda foldername: convert_utf7_to_utf8(foldername)

"""
import re


def convert_utf7_to_utf8(str_imap):
    """
    This function converts an IMAP_UTF-7 string object to UTF-8.
    It first replaces the ampersand (&) character with plus character (+)
    in the cases of UTF-7 character and then decode the string to utf-8.

    If the str_imap string is already UTF-8, return it.

    For example, "abc&AK4-D" is translated to "abc+AK4-D"
    and then, to "abc@D"

    Example code:
    my_string = "abc&AK4-D"
    print(kix_utf7_to_utf8(my_string))

    Args:
        bytes_imap: IMAP UTF7 string

    Returns: UTF-8 string

    Source: https://github.com/OfflineIMAP/offlineimap3/issues/23

    """
    try:
        str_utf7 = re.sub(r"&(\w{3}\-)", "+\\1", str_imap)
        str_utf8 = str_utf7.encode("utf-8").decode("utf_7")
        return str_utf8
    except UnicodeDecodeError:
        # error decoding because already utf-8, so return original string
        return str_imap
