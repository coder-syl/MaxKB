GitHub 上 fork 下来的库默认不会自动同步主库（upstream），要你自己拉、自己合并，自己推上去！

✅ 1️⃣ 先给 fork 配好 “上游（upstream）”
# 进入你的本地 repo
cd allen/xxx
 
# 添加上游地址（把 USER/REPO 换成主项目）
git remote add upstream https://github.com/USER/xxx.git
 
# 检查一下
git remote -v
看到 upstream 和 origin 都有就对了。

✅ 2️⃣ 拉取主项目（upstream）的最新改动
git fetch upstream
这时你本地就多了 upstream/main（或 upstream/master）。

✅ 3️⃣ 合并主项目的更新到你的分支
假设你的分支叫 main：

# 切到你的分支
git checkout main
 
# 合并上游
git merge upstream/main
✅ 4️⃣ 如果有冲突，手动解决，解决后记得：
git add .
git commit -m "Merge upstream"
✅ 5️⃣ 把合并后的新内容推到你的 fork 仓库
git push origin main
这样，你 allen/xxx 就和主项目同步了。

✅ 🌟 如果想“自动化”，可以设置 GitHub Action 或本地脚本
👉 最省事：

在自己机器上写个 sync.sh，放个定时任务（cron），每天执行一次上面这几步。
👉 要想 GitHub 自动跑：

配置一个简单的 GitHub Action（比如 pull_request.yml），定时触发 git pull upstream 然后 push 到 origin。
✅ ⚡️ 一句话结论
GitHub 的 fork 永远是静态快照，不会自动帮你跟主库同步，自己加 upstream、自己定时 fetch + merge，才是正道。