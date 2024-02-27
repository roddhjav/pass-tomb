#!/usr/bin/env bash
# Tomb manager - Password Store Extension (https://www.passwordstore.org/)
# Copyright (C) 2017-2024 Alexandre PUJOL <alexandre@pujol.io>.
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2068,SC1090

if [[ -x "${PASSWORD_STORE_EXTENSIONS_DIR}/tomb.bash" ]]; then
	source "${PASSWORD_STORE_EXTENSIONS_DIR}/tomb.bash"
elif [[ -x "${SYSTEM_EXTENSION_DIR}/tomb.bash" ]]; then
	source "${SYSTEM_EXTENSION_DIR}/tomb.bash"
else
	die "Unable to load the pass tomb extension."
fi

cmd_close "$@"
