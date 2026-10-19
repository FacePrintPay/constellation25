export default (req, res) => res.status(200).json({
  ok:true, app:"repodepot", git_sha:process.env.GIT_SHA||"unknown",
  queue_depth:Number(process.env.QUEUE_DEPTH||0)
});
