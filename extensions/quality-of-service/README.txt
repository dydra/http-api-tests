## Quality Of Service provisions

### Install The Facility

#### Nginx Configuration

The Nginx configuration involve two aspects.
The basis is the set of upstream hosts. These arrange for a collection of upstream processors
to be available for each quality class.
The resource allocation is determined by the upstream host which is specified in each view's respective location declaration.

The upstream hosts are recorded in the system/system repository.
From these the upstream entries are generated and manually incorporated in

    /opt/rails/etc/nginx/dydra/upstream/spocq-upstream.conf

view specific locations are generated from the contents of the
<http://dydra.com/quality-of-service/views> and <http://dydra.com/quality-of-service> graphs
in an account's system repository.
These are stored in the account's respective .conf file in the directory

    /opt/rails/etc/nginx/dydra/spocq/qos/

These are included by a general qos route configuration file

    /opt/rails/etc/nginx/dydra/spocq/qos.conf

It must include a reference to the account's location configuration file in order for them to be active.
The account configuration file is generated as a side-effect of updating the account's quality-of-service repository

QOS for non-view locations is managed by recognizing a quality-of-service header.
This is passed through an identity map to validate the header and to establish a default which falls back to the general pattern-based locations.

  map $http_quality_of_service $upstream {
    Administration Administration;
    Queued Queued;
    SPARQL SPARQL;
    Scheduled Scheduled;
    Service Service;
    default spocq; # legacy
  }

#### Systemd configuration

Each upstream processor is defined by a systemd .service file which determines the executed binary, the initialization arguments and the configuration file.
The binaries are all spocq-server.
The arguments and configurations allow for
- varied heap sizes
- maximum simultaneous request counts
- maximum pending request queue lengths.

each instance is associated with its own /opt/spocq/init-http-127-0-0-1-???.sxp initialization file.


#### Account configuration

Introduce the quality-of-service repository

### Tests

update-qos.sh
- alternatively update the qos repository with one or another variant configuration
- allow propagation to the system repository and generation of the locations
- retrieve the locations and verify

update-qos-invalid.sh
- attempt to import invalid locations to verify constraints.

