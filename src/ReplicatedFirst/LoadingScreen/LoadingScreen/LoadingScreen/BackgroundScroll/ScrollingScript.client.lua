local TS = game:GetService("TweenService")

local frame = script.Parent
local info = frame.Parent.Info
local loadingLabel = info.Loading

local TInfo = TweenInfo.new(12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
local ScrollTween = TS:Create(frame, TInfo, {CanvasPosition = Vector2.new(682,0)})

while true do
	frame.CanvasPosition = Vector2.new(05,0)
	ScrollTween:Play()
	loadingLabel.Text = "Loading"
	task.wait(2.5)
	loadingLabel.Text = "Loading."
	task.wait(2.5)
	loadingLabel.Text = "Loading.."
	task.wait(2.5)
	loadingLabel.Text = "Loading..."
	task.wait(2.5)
end