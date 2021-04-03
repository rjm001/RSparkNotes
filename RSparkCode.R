system("java -version") #11.0.10
# require Java because Spark is built in Scala which is run by the Java Virtual Machine. So, just needed to verify you have it.

library(pacman)
p_load(sparklyr)
packageVersion("sparklyr")
spark_available_versions()
# note, they used 2.3 for the tutorial
# spark_install("2.3")
# now up to version 3!
#spark_install()
spark_installed_versions()
# spark_uninstall("2.3") # to remove version 2.3
# note, java 11 is only supported for spark 3.0.0+
options(timeout=300)
spark_install("3.0")

## connect to local cluster
sc <- spark_connect(master = "local", version="3.0")
# master is "main" machine for spark cluster, aka the driver node.
cars <- copy_to(sc, mtcars)
cars

spark_web(sc) # this is pretty cool; it opens up a dashboard of all your jobs on the cluster

p_load(DBI) #for SQL queries
dbGetQuery(sc, "SELECT count(*) FROM mtcars")

p_load(tidyverse) #for dplyr queries, which are recommended over SQL queries
count(cars) # same as DB query above
select(cars, hp, mpg) %>%
    sample_n(100) %>%
    collect() %>%
    plot()
# note this regression function (ml_linear_regression) is a sparklyr function
# vs if run it with lm(mpg ~ hp, cars), just runs it locally?
model <- ml_linear_regression(cars, mpg ~ hp)
model
model %>% 
    ml_predict(copy_to(sc, data.frame(hp=250 + 10*1:10))) %>%
    transmute(hp = hp, mpg = prediction) %>%
    full_join(select(cars,hp,mpg)) %>%
    collect() %>%
    plot()
# setwd("my/working/directory")
# spark_write_csv(cars, "cars.csv") # write data from spark session
# cars <- spark_read_csv(sc, "cars.csv") # read data into spark session
p_load(sparklyr.nested)
# nested useful for JSON files that contain nested lists that require preprocessing
sparklyr.nested::sdf_nest(cars, hp) %>%
    group_by(cyl) %>%
    summarise(data = collect_list(data))
# can use with spark_read_json()/spark_write_json()

# Writing your own R functions with spark can be done with spark_apply, but is highly discouraged in general!
cars %>% spark_apply(~round(.x)) 
# creating a data set we will stream in
dir.create("input")
write.csv(mtcars, "input/cars_1.csv", row.names=F)
stream <- stream_read_csv(sc, "input/") %>%
    select(mpg, cyl, disp) %>%
    stream_write_csv("output/")

dir("output", pattern=".csv")

# adding more files and Spark parallelizes and processes teh data automatically
# write.csv(mtcars)

# spark_disconnect(sc)
# spark_disconnect_all()

