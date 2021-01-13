#!/bin/bash


helpFunction()
{
   echo ""
   echo "Usage: $0 -p protocol -i instance -d domain"
   echo -e "\t-p protocol of new instance"
   echo -e "\t-i name of new instance. For blank instance name (production) use value of 'none'."
   echo -e "\t-d domain of new instance"
   exit 1 # Exit script after printing help
}

while getopts "p:d:i:" opt
do
   case "$opt" in
      p ) protocol="$OPTARG" ;;
      d ) domain="$OPTARG" ;;
      i ) instance="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$protocol" ] || [ -z "$domain" ] || [ -z "$instance" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# If instance = 'none' set it to blank.
if [ $instance = 'none' ]
then
   instance='';
fi

# Set studio and lms instance names.
studioinstance="$instance"studio;
lmsinstance="$instance"lms;

src=/edx/app/edxapp/lms.env.json
dest=/edx/app/edxapp/lms.env.json.orig

printf "\n\n********************************\n"
printf "Working on $src\n"
printf "source file = $src\n"

if [ -f "$dest" ]; then
    printf "$dest exists, not overwriting.\n"
else
    printf "copying $src to $dest to keep an original copy\n"
    sudo cp $src $dest
fi

sudo sed -i s/\"CMS_BASE\":.*/'"CMS_BASE": "'$studioinstance.$domain'",'/ $src
sudo sed -i s/\"ENTERPRISE_API_URL\":.*/'"ENTERPRISE_API_URL": "'$protocol:\\/\\/$lmsinstance.$domain\\/enterprise\\/api\\/v1\\/'",'/ $src
sudo sed -i s/\"ENTERPRISE_ENROLLMENT_API_URL\":.*/'"ENTERPRISE_ENROLLMENT_API_URL": "'$protocol:\\/\\/$lmsinstance.$domain\\/api\\/enrollment\\/v1\\/'",'/ $src
sudo sed -i s/\"PREVIEW_LMS_BASE\":.*/'"PREVIEW_LMS_BASE": "'preview.$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"JOURNALS_API_URL\":.*/'"JOURNALS_API_URL": "'$protocol:\\/\\/journals-$lmsinstance.$domain\\/api\\/v1\\/'",'/ $src
sudo sed -i s/\"LMS_BASE\":.*/'"LMS_BASE": "'$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"LMS_INTERNAL_ROOT_URL\":.*/'"LMS_INTERNAL_ROOT_URL": "'$protocol:\\/\\/$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"LMS_ROOT_URL\":.*/'"LMS_ROOT_URL": "'$protocol:\\/\\/$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"OAUTH_OIDC_ISSUER\":.*/'"OAUTH_OIDC_ISSUER": "'$protocol:\\/\\/$lmsinstance.$domain\\/oauth2'",'/ $src
sudo sed -i s/\"SITE_NAME\":.*/'"SITE_NAME": "'$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"ENABLE_MOBILE_REST_API\":.*/'"ENABLE_MOBILE_REST_API": true,'/ $src
sudo sed -i s/\"ENABLE_HTML_XBLOCK_STUDENT_VIEW_DATA\":.*/'"ENABLE_HTML_XBLOCK_STUDENT_VIEW_DATA": true,'/ $src
sudo sed -i s/\"CORS_ORIGIN_ALLOW_ALL\":.*/'"CORS_ORIGIN_ALLOW_ALL": true,'/ $src
sudo sed -i s/\"ENABLE_CORS_HEADERS\":.*/'"ENABLE_CORS_HEADERS": true,'/ $src
sudo sed -i s/\"OAUTH_ENFORCE_SECURE\":.*/'"OAUTH_ENFORCE_SECURE": true,'/ $src
sudo sed -i s/\"JWT_ISSUER\":.*/'"JWT_ISSUER": "'$protocol:\\/\\/$lmsinstance.$domain\\/oauth2'",'/ $src
sudo sed -i s/\"ISSUER\":.*/'"ISSUER": "'$protocol:\\/\\/$lmsinstance.$domain\\/oauth2'",'/ $src
sudo sed -i s/\"X_FRAME_OPTIONS\":.*/'"X_FRAME_OPTIONS": "ALLOW",'/ $src
sudo sed -i s/\"city\":.*/'"city": "hidden"',/ $src
sudo sed -i s/\"confirm_email\":.*/'"confirm_email": "hidden"',/ $src
sudo sed -i s/\"country\":.*/'"country": "hidden"',/ $src
sudo sed -i s/\"gender\":.*/'"gender": "hidden"',/ $src
sudo sed -i s/\"goals\":.*/'"goals": "hidden"',/ $src
sudo sed -i s/\"honor_code\":.*/'"honor_code": "hidden"',/ $src
sudo sed -i s/\"level_of_education\":.*/'"level_of_education": "hidden"',/ $src
sudo sed -i s/\"mailing_address\":.*/'"mailing_address": "hidden"',/ $src
sudo sed -i s/\"terms_of_service\":.*/'"terms_of_service": "hidden"',/ $src
sudo sed -i s/\"year_of_birth\":.*/'"year_of_birth": "hidden"'/ $src
sudo sed -i s/\"DEFAULT_MOBILE_AVAILABLE\":.*/'"DEFAULT_MOBILE_AVAILABLE": true,'/ $src
sudo sed -i s/\"EDXNOTES_INTERNAL_API\":.*/'"EDXNOTES_INTERNAL_API": "'$protocol:\\/\\/notes.$instance.$domain\\/api\\/v1'",'/ $src
sudo sed -i s/\"EDXNOTES_PUBLIC_API\":.*/'"EDXNOTES_PUBLIC_API": "'$protocol:\\/\\/notes.$instance.$domain\\/api\\/v1'",'/ $src
sudo sed -i s/\"ENABLE_EDXNOTES\":.*/'"ENABLE_EDXNOTES": true,'/ $src

if (( $(sudo grep -c "LOGIN_REDIRECT_WHITELIST" $src) )); then
    sudo sed -i '/LOGIN_REDIRECT_WHITELIST/{n;d;}' $src
    sudo sed -i "/LOGIN_REDIRECT_WHITELIST.*/a \        \"$studioinstance.$domain\"" $src
fi

if (( $(sudo grep -c "SESSION_COOKIE_SECURE" $src) )); then
	sudo sed -i "/SESSION_COOKIE_SECURE.*/a \    \"SESSION_ENGINE\": \"django.contrib.sessions.backends.cached_db\"," $src
fi

printf "Done with $src\n"
printf "\n********************************\n"


src=/edx/app/edxapp/cms.env.json
dest=/edx/app/edxapp/cms.env.json.orig

printf "\n\n********************************\n"
printf "Working on $src\n"
printf "source file = $src\n"

if [ -f "$dest" ]; then
    printf "$dest exists, not overwriting.\n"
else
    printf "copying $src to $dest to keep an original copy\n"
    sudo cp $src $dest
fi


sudo sed -i s/\"CMS_BASE\":.*/'"CMS_BASE": "'$studioinstance.$domain'",'/ $src
sudo sed -i s/\"ENTERPRISE_API_URL\":.*/'"ENTERPRISE_API_URL": "'$protocol:\\/\\/$lmsinstance.$domain\\/enterprise\\/api\\/v1\\/'",'/ $src
sudo sed -i s/\"PREVIEW_LMS_BASE\":.*/'"PREVIEW_LMS_BASE": "'$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"JOURNALS_API_URL\":.*/'"JOURNALS_API_URL": "'$protocol:\\/\\/journals-$lmsinstance.$domain\\/api\\/v1\\/'",'/ $src
sudo sed -i s/\"JOURNALS_URL_ROOT\":.*/'"JOURNALS_URL_ROOT": "'$protocol:\\/\\/journals-$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"LMS_BASE\":.*/'"LMS_BASE": "'$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"LMS_INTERNAL_ROOT_URL\":.*/'"LMS_INTERNAL_ROOT_URL": "'$protocol:\\/\\/$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"LMS_ROOT_URL\":.*/'"LMS_ROOT_URL": "'$protocol:\\/\\/$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"OAUTH_OIDC_ISSUER\":.*/'"OAUTH_OIDC_ISSUER": "'$protocol:\\/\\/$lmsinstance.$domain\\/oauth2'",'/ $src
sudo sed -i s/\"SITE_NAME\":.*/'"SITE_NAME": "'$lmsinstance.$domain'",'/ $src
sudo sed -i s/\"DEFAULT_MOBILE_AVAILABLE\":.*/'"DEFAULT_MOBILE_AVAILABLE": true,'/ $src
sudo sed -i s/\"X_FRAME_OPTIONS\":.*/'"X_FRAME_OPTIONS": "ALLOW",'/ $src


if (( $(sudo grep -c "LOGIN_REDIRECT_WHITELIST" $src) )); then
    sudo sed -i '/LOGIN_REDIRECT_WHITELIST/{n;d;}' $src
    sudo sed -i "/LOGIN_REDIRECT_WHITELIST.*/a \        \"$studioinstance.$domain\"" $src
fi

if (( $(sudo grep -c "SESSION_COOKIE_SECURE" $src) )); then
	sudo sed -i "/SESSION_COOKIE_SECURE.*/a \    \"SESSION_ENGINE\": \"django.contrib.sessions.backends.cached_db\"," $src
fi

printf "Done with $src\n"
printf "\n********************************\n"

printf "\n\n********************************\n"
printf "Generating RSA key\n"
sudo openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /etc/nginx/cert -keyout /etc/nginx/key -subj "/CN=$instance.$domain"

printf "Done with generating RSA key\n"
printf "\n********************************\n"

src=/edx/app/nginx/sites-available/cms
dest=/edx/app/nginx/sites-available/cms.orig

printf "\n\n********************************\n"
printf "Working on $src\n"
printf "source file = $src\n"

if [ -f "$dest" ]; then
    printf "$dest exists, not overwriting.\n"
else
    printf "copying $src to $dest to keep an original copy\n"
    sudo cp $src $dest
fi

sudo sed -i '/server_name.*/ s/^#*/#/' $src
sudo sed -i 0,/.*server_name.*/s/.*server_name.*/"  server_name $studioinstance.$domain;"/ $src
if (( $(sudo grep -c "server_name $studioinstance.$domain;" $src) )); then
    sudo sed -i "/server_name $studioinstance.$domain;.*/a \  \server_name *.$studioinstance.$domain;" $src
fi
sudo sed -i s'/listen 18010 ;/listen 443 ssl;/' $src

if (( $(sudo grep -c "listen 443 ssl;" $src) )); then
	sudo sed -i "/listen 443 ssl;/a \  \ssl_certificate_key /etc/nginx/key;" $src
	sudo sed -i "/listen 443 ssl;/a \  \ssl_certificate /etc/nginx/cert;" $src
	sudo sed -i "/listen 443 ssl;/a \ \ " $src
fi

printf "Done with $src\n"
printf "\n********************************\n"

src=/edx/app/nginx/sites-available/lms
dest=/edx/app/nginx/sites-available/lms.orig

printf "\n\n********************************\n"
printf "Working on $src\n"
printf "source file = $src\n"

if [ -f "$dest" ]; then
    printf "$dest exists, not overwriting.\n"
else
    printf "copying $src to $dest to keep an original copy\n"
    sudo cp $src $dest
fi

sudo sed -i s'/listen 80 default_server;/listen 443 ssl default_server;/' $src

if (( $(sudo grep -c "listen 443 ssl default_server;" $src) )); then
	sudo sed -i "/listen 443 ssl default_server;/a \  \ssl_certificate_key /etc/nginx/key;" $src
	sudo sed -i "/listen 443 ssl default_server;/a \  \ssl_certificate /etc/nginx/cert;" $src
	sudo sed -i "/listen 443 ssl default_server;/a \ \ " $src
fi

printf "Done with $src\n"
printf "\n********************************\n"

src=/edx/app/edxapp/edx-platform/common/djangoapps/third_party_auth
dest=/edx/app/edxapp/edx-platform/common/djangoapps/third_party_auth_old

printf "\n\n********************************\n"
printf "Working on third party auth.\n"
printf "source directory = $src\n"

sudo mv $src $dest

printf "Moved $src to $dest\n"

sudo -Hu edxapp /edx/bin/pip.edxapp install git+https://github.com/cisco-ibleducation/cisco-third-party-auth-master

printf "Installed cisco-third-party-auth from IBL repo.\n"
printf "\n********************************\n"

src=/edx/app/edxapp/edx-platform/cms/envs/common.py
dest=/edx/app/edxapp/edx-platform/cms/envs/common.py.orig

printf "\n\n********************************\n"
printf "Working on $src\n"
printf "source file = $src\n"

if [ -f "$dest" ]; then
    printf "$dest exists, not overwriting.\n"
else
    printf "copying $src to $dest to keep an original copy\n"
    sudo cp $src $dest
fi

sudo sed -i s/MANAGER_BASE_URL.*/"MANAGER_BASE_URL = \'$protocol:\\/\\/manager.$lmsinstance.$domain'"/ $src
sudo sed -i s/"# IBL_WEBEX_REDIRECT_URI.*"/"IBL_WEBEX_REDIRECT_URI = \'$protocol:\\/\\/interactive.$instance.$domain\\/oauth\\/redirect\\/webex'"/ $src
sudo sed -i s/"# IBL_CALENDAR_FRONTEND_URL.*"/"IBL_CALENDAR_FRONTEND_URL = \'$protocol:\\/\\/interactive.$instance.$domain\\/calendar\\/'"/ $src
sudo sed -i s/"# IBL_BADGE_FRONTEND_URL.*"/"IBL_BADGE_FRONTEND_URL = \'$protocol:\\/\\/interactive.$instance.$domain\\/credentials\\/'"/ $src
sudo sed -i s/"# IBL_WEBEX_ADMIN_FRONTEND_URL.*"/"IBL_WEBEX_ADMIN_FRONTEND_URL = \'$protocol:\\/\\/interactive.$instance.$domain\\/webex-auth\\/'"/ $src

printf "Done with $src\n"
printf "\n********************************\n"


src=/edx/app/edxapp/edx-platform/lms/envs/common.py
dest=/edx/app/edxapp/edx-platform/lms/envs/common.py.orig

printf "\n\n********************************\n"
printf "Working on $src\n"
printf "source file = $src\n"

if [ -f "$dest" ]; then
    printf "$dest exists, not overwriting.\n"
else
    printf "copying $src to $dest to keep an original copy\n"
    sudo cp $src $dest
fi

sudo sed -i s/\'ENABLE_MOBILE_REST_API\':.*/"\'ENABLE_MOBILE_REST_API\': True,"/ $src
sudo sed -i s/\'ENABLE_HTML_XBLOCK_STUDENT_VIEW_DATA\':.*/"\'ENABLE_HTML_XBLOCK_STUDENT_VIEW_DATA\': True,"/ $src
sudo sed -i s/\'ENABLE_THIRD_PARTY_AUTH\':.*/"\'ENABLE_THIRD_PARTY_AUTH\': True,"/ $src
sudo sed -i s/MANAGER_BASE_URL.*/"MANAGER_BASE_URL = \'$protocol:\\/\\/manager.$lmsinstance.$domain'"/ $src
sudo sed -i s/"# IBL_WEBEX_REDIRECT_URI.*"/"IBL_WEBEX_REDIRECT_URI = \'$protocol:\\/\\/interactive.$instance.$domain\\/oauth\\/redirect\\/webex'"/ $src
sudo sed -i s/"# IBL_CALENDAR_FRONTEND_URL.*"/"IBL_CALENDAR_FRONTEND_URL = \'$protocol:\\/\\/interactive.$instance.$domain\\/calendar\\/'"/ $src
sudo sed -i s/"# IBL_BADGE_FRONTEND_URL.*"/"IBL_BADGE_FRONTEND_URL = \'$protocol:\\/\\/interactive.$instance.$domain\\/credentials\\/'"/ $src
sudo sed -i s/"# IBL_WEBEX_ADMIN_FRONTEND_URL.*"/"IBL_WEBEX_ADMIN_FRONTEND_URL = \'$protocol:\\/\\/interactive.$instance.$domain\\/webex-auth\\/'"/ $src
sudo sed -i s/IBL_ALLOW_CALENDAR_IFRAME.*/"IBL_ALLOW_CALENDAR_IFRAME = True"/ $src
sudo sed -i s/IBL_ALLOW_BADGE_IFRAME.*/"IBL_ALLOW_BADGE_IFRAME = True"/ $src


if (( ! $(sudo grep -c "third_party_auth.backends.KeycloakOAuth2" $src) )); then
    sudo sed -i "/^AUTHENTICATION_BACKENDS.*/a \    \'third_party_auth.backends.KeycloakOAuth2'," $src
fi

printf "Done with $src\n"
printf "\n********************************\n"


printf "\n\n********************************\n"
printf "Reestarting supervisor.\n"

/edx/bin/supervisorctl restart lms cms

printf "Restarted lms and cms supervisors.\n"


printf "\n\n********************************\n"
printf "Run migrations for third_party_auth\n"

/edx/bin/edxapp-migrate-lms

printf "Done migrating third_party_auth\n"
printf "\n********************************\n"

printf "\n********************************\n"
printf "PLEASE READ THIS.\n"
printf "Done with all the file modifications\n"
printf "Steps yet to be done:\n"
printf "Additional steps configuring Calendar and Badging at bottom of cms/envs/common.py and lms/envs/common.py\n"
printf "Copy static files from old server to new server\n"
printf "Restart supervisor and nginx\n"
printf "Configure Django Admin\n"
printf "Configure Keycloak\n"
