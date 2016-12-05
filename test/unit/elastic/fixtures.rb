# frozen_string_literal: true
require 'hashie'

module AggregationsFixtures
  def self.load
    Hashie::Mash.new(response)
  end
  def self.response
    { 'global' =>
     { 'doc_count' => 42,
       'item_style_accessories' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 41 }] },
       'item_style_bag' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 41 }] },
       'item_style_outerwear' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 40 }] },
       'color' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'black', 'doc_count' => 12 },
        { 'key' => '', 'doc_count' => 6 },
        { 'key' => 'blue', 'doc_count' => 4 },
        { 'key' => 'brown', 'doc_count' => 4 },
        { 'key' => 'gold', 'doc_count' => 3 },
        { 'key' => 'cream', 'doc_count' => 2 },
        { 'key' => 'green', 'doc_count' => 2 },
        { 'key' => 'pink', 'doc_count' => 2 },
        { 'key' => 'red', 'doc_count' => 2 },
        { 'key' => 'white', 'doc_count' => 2 },
        { 'key' => 'assign your own color', 'doc_count' => 1 },
        { 'key' => 'print', 'doc_count' => 1 },
        { 'key' => 'yellow', 'doc_count' => 1 }] },
       'item_type' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'dress', 'doc_count' => 37 },
        { 'key' => 'bag', 'doc_count' => 4 },
        { 'key' => 'accessories', 'doc_count' => 1 }] },
       'item_style_dress' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'bridesmaid', 'doc_count' => 7 },
        { 'key' => 'formal', 'doc_count' => 5 },
        { 'key' => 'ball', 'doc_count' => 4 },
        { 'key' => 'cocktail', 'doc_count' => 4 },
        { 'key' => 'evening', 'doc_count' => 4 },
        { 'key' => 'guest', 'doc_count' => 4 },
        { 'key' => 'wedding', 'doc_count' => 4 },
        { 'key' => 'races', 'doc_count' => 3 },
        { 'key' => 'work function', 'doc_count' => 3 },
        { 'key' => 'black tie', 'doc_count' => 1 },
        { 'key' => 'daytime', 'doc_count' => 1 }] },
       'designer_name' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => '', 'doc_count' => 9 },
        { 'key' => '321', 'doc_count' => 5 },
        { 'key' => 'amelie pichard', 'doc_count' => 4 },
        { 'key' => '22/4 by stephanie hahn', 'doc_count' => 3 },
        { 'key' => 'alex perry', 'doc_count' => 3 },
        { 'key' => '3.1 phillip lim', 'doc_count' => 2 },
        { 'key' => 'adam heath', 'doc_count' => 2 },
        { 'key' => "ae'lkemi", 'doc_count' => 1 },
        { 'key' => 'alamour', 'doc_count' => 1 },
        { 'key' => 'and re walker', 'doc_count' => 1 },
        { 'key' => 'anine bing', 'doc_count' => 1 },
        { 'key' => 'bailey 44', 'doc_count' => 1 },
        { 'key' => 'carla zampatti', 'doc_count' => 1 },
        { 'key' => 'george', 'doc_count' => 1 },
        { 'key' => 'louis vuitton vintage', 'doc_count' => 1 },
        { 'key' => 'maticevski', 'doc_count' => 1 },
        { 'key' => 'portia and scarlett', 'doc_count' => 1 },
        { 'key' => 'rachel gilbert', 'doc_count' => 1 },
        { 'key' => 'self portrait', 'doc_count' => 1 },
        { 'key' => 'willow', 'doc_count' => 1 },
        { 'key' => 'zimmerman', 'doc_count' => 1 }] },
       'outerwear_size' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 11 }] },
       'dress_size' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'one size', 'doc_count' => 19 },
        { 'key' => '8', 'doc_count' => 6 },
        { 'key' => '', 'doc_count' => 5 },
        { 'key' => '10', 'doc_count' => 4 },
        { 'key' => '6', 'doc_count' => 3 },
        { 'key' => '12', 'doc_count' => 2 },
        { 'key' => '2', 'doc_count' => 2 },
        { 'key' => '16', 'doc_count' => 1 }] },
       'dress_length' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'floor length', 'doc_count' => 11 },
        { 'key' => '', 'doc_count' => 10 },
        { 'key' => 'knee length', 'doc_count' => 10 },
        { 'key' => 'mini', 'doc_count' => 5 },
        { 'key' => 'midi', 'doc_count' => 2 }] },
       'milinery_size' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 1 }] },
       'millinery_size' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => '', 'doc_count' => 32 }, { 'key' => 'one size', 'doc_count' => 10 }] },
       'item_style_milinery' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [] } },
      'filtered_aggregations' =>
     { 'doc_count' => 42,
       'minimum_price' => { 'value' => 200.0 },
       'distinct_locations' => { 'value' => 22 },
       'maximum_price' => { 'value' => 100_000.0 } },
      'custom_attributes' =>
     { 'doc_count' => 42,
       'item_style_accessories' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 41 }] },
       'item_style_bag' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 41 }] },
       'item_style_outerwear' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 40 }] },
       'color' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'black', 'doc_count' => 12 },
        { 'key' => '', 'doc_count' => 6 },
        { 'key' => 'blue', 'doc_count' => 4 },
        { 'key' => 'brown', 'doc_count' => 4 },
        { 'key' => 'gold', 'doc_count' => 3 },
        { 'key' => 'red', 'doc_count' => 2 },
        { 'key' => 'white', 'doc_count' => 2 },
        { 'key' => 'assign your own color', 'doc_count' => 1 },
        { 'key' => 'print', 'doc_count' => 1 },
        { 'key' => 'yellow', 'doc_count' => 1 }] },
       'item_type' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'dress', 'doc_count' => 37 },
        { 'key' => 'bag', 'doc_count' => 4 },
        { 'key' => 'accessories', 'doc_count' => 1 }] },
       'item_style_dress' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'bridesmaid', 'doc_count' => 7 },
        { 'key' => 'formal', 'doc_count' => 5 },
        { 'key' => 'ball', 'doc_count' => 4 },
        { 'key' => 'cocktail', 'doc_count' => 4 },
        { 'key' => 'evening', 'doc_count' => 4 },
        { 'key' => 'guest', 'doc_count' => 4 },
        { 'key' => 'wedding', 'doc_count' => 4 },
        { 'key' => 'races', 'doc_count' => 3 },
        { 'key' => 'work function', 'doc_count' => 3 },
        { 'key' => 'black tie', 'doc_count' => 1 },
        { 'key' => 'daytime', 'doc_count' => 1 }] },
       'designer_name' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => '', 'doc_count' => 9 },
        { 'key' => '321', 'doc_count' => 5 },
        { 'key' => 'amelie pichard', 'doc_count' => 4 },
        { 'key' => 'willow', 'doc_count' => 1 },
        { 'key' => 'zimmerman', 'doc_count' => 1 }] },
       'outerwear_size' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 11 }] },
       'dress_size' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'one size', 'doc_count' => 19 },
        { 'key' => '8', 'doc_count' => 6 },
        { 'key' => '', 'doc_count' => 5 },
        { 'key' => '10', 'doc_count' => 4 },
        { 'key' => '6', 'doc_count' => 3 },
        { 'key' => '12', 'doc_count' => 2 },
        { 'key' => '2', 'doc_count' => 2 },
        { 'key' => '16', 'doc_count' => 1 }] },
       'dress_length' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => 'floor length', 'doc_count' => 11 },
        { 'key' => '', 'doc_count' => 10 },
        { 'key' => 'knee length', 'doc_count' => 10 },
        { 'key' => 'mini', 'doc_count' => 5 },
        { 'key' => 'midi', 'doc_count' => 2 }] },
       'milinery_size' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [{ 'key' => '', 'doc_count' => 1 }] },
       'millinery_size' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' =>
       [{ 'key' => '', 'doc_count' => 32 }, { 'key' => 'one size', 'doc_count' => 10 }] },
       'item_style_milinery' =>
      { 'doc_count_error_upper_bound' => 0,
        'sum_other_doc_count' => 0,
        'buckets' => [] } } }
  end
end
