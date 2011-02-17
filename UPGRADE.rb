Design.remove
MongoODM.database['Design'].find.each do |design|
  design.delete('_id')
  Design.new(design).save
end

Site.remove
MongoODM.database['Site'].find.each do |site|
  site.delete('_id')
  site.delete('design')
  Site.new(site).save
end

User.remove
MongoODM.database['User'].find.each do |user|
  user.delete('_id')
  login_at = user.delete('last_login')
  u = User.new(user)
  u.login_at = login_at
  u.save
end

MongoODM.database['Page'].find.each do |page|
  page.delete('_id')
  Page.new(page).save
end

MongoODM.database['Post'].find.each do |post|
  post.delete('_id')
  published_at = post.delete('date')
  updated_at = post.delete('updated')
  p = Post.new(post)
  p.updated_at = updated_at
  p.created_at = updated_at
  p.published_at = published_at
  p.save
end

