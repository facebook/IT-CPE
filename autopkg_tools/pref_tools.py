#!/usr/bin/env python2

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

from cpe.pyexec.core import cpe_exceptions

try:
    from Foundation import NSDate
    from Foundation import CFPreferencesAppSynchronize
    from Foundation import CFPreferencesCopyAppValue
    from Foundation import CFPreferencesSetValue
    from Foundation import kCFPreferencesCurrentUser
    from Foundation import kCFPreferencesCurrentHost
except ImportError:
    pass


def get_pref(pref_name, bundleid):
    """Get preference value for key from domain."""
    try:
        pref_value = CFPreferencesCopyAppValue(pref_name, bundleid)
    except NameError:
        # NameError occurs if this couldn't be imported, likely due to
        # wrong platform
        raise cpe_exceptions.PyexecWrongPlatformException(
            'Darwin',
            'pref_tools.get_pref'
        )
    if isinstance(pref_value, NSDate):
        # convert NSDate/CFDates to strings
        pref_value = str(pref_value)
    return pref_value


def set_pref(pref_name, pref_value, bundleid):
    """Set a preference, writing it to ~/Library/Preferences/."""
    try:
        CFPreferencesSetValue(
            pref_name, pref_value, bundleid, kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
        CFPreferencesAppSynchronize(bundleid)
    except NameError:
        # NameError occurs if this couldn't be imported, likely due to
        # wrong platform
        raise cpe_exceptions.PyexecWrongPlatformException(
            'Darwin',
            'pref_tools.set_pref'
        )
    except Exception:
        pass
