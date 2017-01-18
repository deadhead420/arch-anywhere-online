<?php

if (!defined('PUN')) exit;
define('PUN_QJ_LOADED', 1);
$forum_id = isset($forum_id) ? $forum_id : 0;

?>				<form id="qjump" method="get" action="viewforum.php">
					<div><label><span><?php echo $lang_common['Jump to'] ?><br /></span>
					<select name="id" onchange="window.location=('viewforum.php?id='+this.options[this.selectedIndex].value)">
						<optgroup label="Arch Anywhere Installer">
							<option value="3"<?php echo ($forum_id == 3) ? ' selected="selected"' : '' ?>>Announcement / Release</option>
							<option value="5"<?php echo ($forum_id == 5) ? ' selected="selected"' : '' ?>>Suggestions / Enhancements</option>
						</optgroup>
						<optgroup label="Tutorials / How To">
							<option value="11"<?php echo ($forum_id == 11) ? ' selected="selected"' : '' ?>>General Guides</option>
							<option value="10"<?php echo ($forum_id == 10) ? ' selected="selected"' : '' ?>>Install Tutorials</option>
						</optgroup>
						<optgroup label="General Discussion">
							<option value="6"<?php echo ($forum_id == 6) ? ' selected="selected"' : '' ?>>GNU/Linux General Discussion</option>
							<option value="9"<?php echo ($forum_id == 9) ? ' selected="selected"' : '' ?>>Programming &amp; Scripting</option>
						</optgroup>
					</select></label>
					<input type="submit" value="<?php echo $lang_common['Go'] ?>" accesskey="g" />
					</div>
				</form>
