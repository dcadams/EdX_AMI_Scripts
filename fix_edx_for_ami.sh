#!/bin/bash


helpFunction()
{
   echo ""
   echo "Usage: $0 -p protocol -i instance -d domain"
   echo -e "\t-p protocol of new instance"
   echo -e "\t-i name of new instance. For blank instance name use value of 'none'."
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

# If instance = 'none' set it to blank, otherwise add '.' on end.
if [ $instance = 'none' ]
then
   instance='';
else
   instance=$instance"."
fi

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

sudo sed -i s/\"CMS_BASE\":.*/'"CMS_BASE": "'studio.$instance$domain'",'/ $src
sudo sed -i s/\"ENTERPRISE_API_URL\":.*/'"ENTERPRISE_API_URL": "'$protocol:\\/\\/$instance$domain\\/enterprise\\/api\\/v1\\/'",'/ $src
sudo sed -i s/\"ENTERPRISE_ENROLLMENT_API_URL\":.*/'"ENTERPRISE_ENROLLMENT_API_URL": "'$protocol:\\/\\/$instance$domain\\/api\\/enrollment\\/v1\\/'",'/ $src
sudo sed -i s/\"PREVIEW_LMS_BASE\":.*/'"PREVIEW_LMS_BASE": "'preview.$instance$domain'",'/ $src
sudo sed -i s/\"JOURNALS_API_URL\":.*/'"JOURNALS_API_URL": "'$protocol:\\/\\/journals-$instance$domain\\/api\\/v1\\/'",'/ $src
sudo sed -i s/\"LMS_BASE\":.*/'"LMS_BASE": "'$instance$domain'",'/ $src
sudo sed -i s/\"LMS_INTERNAL_ROOT_URL\":.*/'"LMS_INTERNAL_ROOT_URL": "'$protocol:\\/\\/$instance$domain'",'/ $src
sudo sed -i s/\"LMS_ROOT_URL\":.*/'"LMS_ROOT_URL": "'$protocol:\\/\\/$instance$domain'",'/ $src
sudo sed -i s/\"OAUTH_OIDC_ISSUER\":.*/'"OAUTH_OIDC_ISSUER": "'$protocol:\\/\\/$instance$domain\\/oauth2'",'/ $src
sudo sed -i s/\"SITE_NAME\":.*/'"SITE_NAME": "'$instance$domain'",'/ $src

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


sudo sed -i s/\"CMS_BASE\":.*/'"CMS_BASE": "'studio.$instance$domain'",'/ $src
sudo sed -i s/\"ENTERPRISE_API_URL\":.*/'"ENTERPRISE_API_URL": "'$protocol:\\/\\/$instance$domain\\/enterprise\\/api\\/v1\\/'",'/ $src
sudo sed -i s/\"PREVIEW_LMS_BASE\":.*/'"PREVIEW_LMS_BASE": "'$instance$domain'",'/ $src
sudo sed -i s/\"JOURNALS_API_URL\":.*/'"JOURNALS_API_URL": "'$protocol:\\/\\/journals-$instance$domain\\/api\\/v1\\/'",'/ $src
sudo sed -i s/\"JOURNALS_URL_ROOT\":.*/'"JOURNALS_URL_ROOT": "'$protocol:\\/\\/journals-$instance$domain'",'/ $src
sudo sed -i s/\"LMS_BASE\":.*/'"LMS_BASE": "'$instance$domain'",'/ $src
sudo sed -i s/\"LMS_INTERNAL_ROOT_URL\":.*/'"LMS_INTERNAL_ROOT_URL": "'$protocol:\\/\\/$instance$domain'",'/ $src
sudo sed -i s/\"LMS_ROOT_URL\":.*/'"LMS_ROOT_URL": "'$protocol:\\/\\/$instance$domain'",'/ $src
sudo sed -i s/\"OAUTH_OIDC_ISSUER\":.*/'"OAUTH_OIDC_ISSUER": "'$protocol:\\/\\/$instance$domain\\/oauth2'",'/ $src
sudo sed -i s/\"SITE_NAME\":.*/'"SITE_NAME": "'$instance$domain'",'/ $src

printf "Done with $src\n"
printf "\n********************************\n"

src=/edx/app/nginx/sites-enabled/cms
dest=/edx/app/nginx/sites-enabled/cms.orig

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
sudo sed -i 0,/.*server_name.*/s/.*server_name.*/"  server_name studio.$instance$domain;"/ $src
if (( $(grep -c "server_name studio.$instance$domain;" $src) )); then
    sudo sed -i "/server_name studio.$instance$domain;.*/a \  \server_name *.studio.$instance$domain;," $src
fi
sudo sed -i s'/listen 18010 ;/listen 80 ;/' $src

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


src=/edx/app/edxapp/edx-platform/lms/envs/common.py
dest=/edx/app/edxapp/edx-platform/lms/envs/common.py.orig

printf "source file = $src\n"

if [ -f "$dest" ]; then
    printf "$dest exists, not overwriting.\n"
else
    printf "copying $src to $dest to keep an original copy\n"
    sudo cp $src $dest
fi

sudo sed -i s/\'ENABLE_THIRD_PARTY_AUTH\':.*/"\'ENABLE_THIRD_PARTY_AUTH\': True,"/ $src
if (( ! $(grep -c "third_party_auth.backends.KeycloakOAuth2" $src) )); then
    sudo sed -i "/^AUTHENTICATION_BACKENDS.*/a \    \'third_party_auth.backends.KeycloakOAuth2'," $src
fi

printf "Done with $src\n"
printf "\n********************************\n"

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

sudo sed -i s/\"city\":.*/'"city": "hidden"',/ $src
sudo sed -i s/\"confirm_email\":.*/'"conform_email": "hidden"',/ $src
sudo sed -i s/\"country\":.*/'"country": "hidden"',/ $src
sudo sed -i s/\"gender\":.*/'"gender": "hidden"',/ $src
sudo sed -i s/\"goals\":.*/'"goals": "hidden"',/ $src
sudo sed -i s/\"honor_code\":.*/'"honor_code": "hidden"',/ $src
sudo sed -i s/\"level_of_education\":.*/'"level_of_education": "hidden"',/ $src
sudo sed -i s/\"mailing_address\":.*/'"mailing_address": "hidden"',/ $src
sudo sed -i s/\"terms_of_service\":.*/'"terms_of_service": "hidden"',/ $src
sudo sed -i s/\"year_of_birth\":.*/'"year_of_birth": "hidden"',/ $src

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
printf "Restart supervisor and nginx\n"
printf "Configure Django Admin\n"
printf "Configure Keycloak\n"

