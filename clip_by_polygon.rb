#!/bin/bash
SUFFIX="ecape"
CLIPTABLE="ecape"
CLIPFIELD="provname"
CLIPGEOMFIELD="the_geom"
CLIPFIELDVALUE="Eastern Cape"
DB="cdsm50k"
DELETETABLE=1
DELETEGEOM=1
SHPDUMP=1
SQLDUMP=0
pushd .
cd /tmp

for TABLE in `echo "\dt" | psql $DB \
    | awk '{print $3}' | grep "^[a-zA-Z]"`

do
  GEOMFIELD=`echo "\d $TABLE" | psql $DB | grep "geometry" \
  | grep -v "geometrytype" |awk '{print $1}'`
  if [ "$GEOMFIELD" == "" ]
  then
    echo "$TABLE has no geometry column, skipping"
  else
    echo "$TABLE -> $GEOMFIELD"
    echo "drop table \"${TABLE}_${SUFFIX}\";" | psql $DB
    # Note we use the && bounding box query first and
    # then the intersects query to avoid unneeded comparison of
    # complex geometries.
    SQL="CREATE TABLE \"${TABLE}_${SUFFIX}\" AS \
            SELECT \
            ST_Intersection(v.$GEOMFIELD, m.$CLIPGEOMFIELD) AS intersection_geom, \
            v.*, \
            m.$CLIPFIELD \
            FROM \
              \"$TABLE\" v, \
              $CLIPTABLE m \
            WHERE \
              ST_Intersects(v.$GEOMFIELD, m.$CLIPGEOMFIELD) AND \
              $CLIPFIELD='$CLIPFIELDVALUE';"

    echo $SQL  | psql $DB

    if [ $DELETEGEOM -eq 1 ]
    then
      echo "alter table \"${TABLE}_${SUFFIX}\" drop column $GEOMFIELD;" | psql $DB
    fi

    if [ $SHPDUMP -eq 1 ]
    then
      pgsql2shp -f ${TABLE}.shp -g "intersection_geom" $DB ${TABLE}_${SUFFIX}
    fi

    if [ $SQLDUMP -eq 1 ]
    then
      pg_dump -D $DB -t ${TABLE}_${SUFFIX} > ${TABLE}_${SUFFIX}.sql
    fi  

    if [ $DELETETABLE -eq 1 ]
    then
      echo "drop table ${TABLE}_${SUFFIX};" | psql $DB
    fi
  fi
done
echo "vacuum analyze;" | psql $DB
popd
