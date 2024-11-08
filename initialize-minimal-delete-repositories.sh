#! /bin/bash

# http api tests : repository creation and content initialization
#set -e
if [[ "" == "${STORE_TOKEN}" ]]
then source ./define.sh
fi

#for account in ${STORE_ACCOUNT} jhacker test; do create_account $account; done

for repository in ${STORE_REPOSITORY} ${STORE_REPOSITORY_WRITABLE} ${STORE_REPOSITORY_PUBLIC} ${STORE_REPOSITORY_PROVENANCE} \
                  foaf collation inference ldp public tpf; do
    delete_repository --repository $repository
done
delete_repository --repository ${STORE_REPOSITORY_REVISIONED}
delete_repository --account test --repository test
delete_repository --account test --repository foaf

echo "NOT DELETING: delete_repository --account system --repository null"
echo "  (as it can only be created again via dydra-admin)"
#delete_repository --account system --repository null
