these tests validate the authorization logic for the following cases:


- account-repository

the query target repository may permit access to the authenticated account.
this is a fall-back when the user/agent itself does not have access


- agent-repository
the query target repository may permit access to the specific user.
this can eb an authenticated user, a located user, or an anonymous user.


- repository-repositry

for intra-site federation, the service location can permit access from the origin repository.


- view-repository

for view-specific access, the view is authorized to perform read/write operations

- agent-view

for cases where the agent is not authorized to access the repository directly, it is possible
to provide access through a view.



