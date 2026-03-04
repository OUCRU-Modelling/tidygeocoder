addr <- "197 Trần Phú, Phường 4, Quận 5, TP. Hồ Chí Minh"

# ==== check api endpoint ====
url <- tidygeocoder:::get_vietmap_url()
url
tidygeocoder:::get_vietmap_url(reverse = TRUE)

# ==== check key getter ====
tidygeocoder::api_key_reference
key <- tidygeocoder:::get_key("vietmap")

# ==== test geocoding code ====
api_query_params <- list(
  text = addr,
  apikey = key,
  display_type=6
)

api_query_params

# First get result from Search API
# uncomment to test querying
# response <- httr::GET(url, query = api_query_params)
httr::warn_for_status(response)

content <- httr::content(response, as = "text", encoding = "UTF-8")
raw_results <- jsonlite::fromJSON(content)


# Then get reference id of the first result
ref_id <- raw_results[1,"ref_id"]

# also get the alternative display address (i.e., new address if display_type = 6)
display_alt <- if(length(raw_results[1,"data_old"]) > 1){
  raw_results[1,"data_old"]["display"][[1]]
}else if(length(raw_results[1,"data_new"]) > 1){
  raw_results[1,"data_new"]["display"][[1]]
}else{
  NULL
}


# Finally, get geocode from Place API
# uncomment to test querying
# geo_response <- httr::GET("https://maps.vietmap.vn/api/place/v4",
#                       query = list(
#                         apikey = key,
#                         refid = ref_id
#                       ))
geo_content <- httr::content(geo_response, as = "text", encoding = "UTF-8")
geo_content

# then add the alternative display text to the full content
# note that this is a workaround for Vietnam which just updated their admin lvl
full_geo_content <- jsonlite::fromJSON(geo_content)
if(!is.null(display_alt)){
  full_geo_content[["display_alt"]] <- display_alt
}
geo_content <- jsonlite::toJSON(full_geo_content)

# ==== Test high level code ====
# uncomment to rerun query
# test_res <- tidygeocoder::query_api(url,
#                                     api_query_params, method="vietmap")
tidygeocoder::extract_results("vietmap", jsonlite::fromJSON(test_res$content))
tidygeocoder::extract_results("vietmap", jsonlite::fromJSON(test_res$content), full_results = FALSE)

# Try geo() function
# uncomment to test querying
# test_out <- tidygeocoder::geo(
#   address = addr,
#   method = "vietmap",
#   lat = latitude,
#   long = longitude,
#   api_options = list(
#     "vietmap_display_type" = 6
#   ),
#   full_results = TRUE
# )

# Try geocode with invalid address
# tidygeocoder::geo(
#     address = "sgherhgewsh",
#     method = "vietmap",
#     lat = latitude,
#     long = longitude,
#     api_options = list(
#       "vietmap_display_type" = 6
#     )
#   )


test_out

