#!/bin/bash

create_resource_group(){
    local rg_name="$1" location="$2"
    if ["$(az group exists -n "$rg_name")" = false]; then
        az group create -n "$rg_name" -l "$location"
    fi
}

create_storage_account(){
    local acct_name="$1" rg_name="$2"
    if ! az storage account show -n "$acct_name" -g "$rg_name" &>/dev/null; then
        az storage account create 
    fi
}