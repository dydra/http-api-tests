#! /bin/bash

# http api tests : repository creation and content initialization
#set -e
if [[ "" == "${STORE_TOKEN}" ]]
then source ./define.sh
fi

#for account in ${STORE_ACCOUNT} jhacker test; do create_account $account; done

for repository in ${STORE_REPOSITORY} ${STORE_REPOSITORY_WRITABLE} ${STORE_REPOSITORY_PUBLIC} ${STORE_REPOSITORY_PROVENANCE} \
                  foaf collation inference ldp public tpf; do
    echo delete_repository --repository $repository
    delete_repository --repository $repository
done
echo delete_repository --account test --repository test
delete_repository --account test --repository test
echo delete_repository --account test --repository foaf
delete_repository --account test --repository foaf
echo NOT DELETING: delete_repository --account system --repository null
#delete_repository --account system --repository null
