-- Sets the display names shown on the home greeting / header for existing accounts.
update auth.users
set raw_user_meta_data = coalesce(raw_user_meta_data,'{}'::jsonb)
  || jsonb_build_object('first_name','Benedict','last_name','Okpala','full_name','Benedict Okpala')
where lower(email) = 'benokpala@ourkiru.com';

update auth.users
set raw_user_meta_data = coalesce(raw_user_meta_data,'{}'::jsonb)
  || jsonb_build_object('first_name','Abayomi','last_name','Cole','full_name','Abayomi Cole')
where lower(email) = 'cole@ourkiru.com';
